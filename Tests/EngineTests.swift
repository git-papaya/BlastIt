import XCTest
@testable import BlockBlastLib

final class EngineTests: XCTestCase {

    func testBitboardPlacement() {
        var board = Board()
        let dot = Piece(shape: .dot1x1, colorIndex: 0)

        // Can place at (0, 0)
        XCTAssertTrue(board.canPlace(piece: dot, atOriginRow: 0, originCol: 0))

        // Place piece
        let result = board.place(piece: dot, atOriginRow: 0, originCol: 0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.clearedRows.count, 0)
        XCTAssertEqual(result?.clearedCols.count, 0)
        XCTAssertTrue(board.isOccupied(row: 0, col: 0))

        // Cannot place another piece on the occupied cell
        XCTAssertFalse(board.canPlace(piece: dot, atOriginRow: 0, originCol: 0))

        // Cannot place outside boundary
        XCTAssertFalse(board.canPlace(piece: dot, atOriginRow: 8, originCol: 0))
        XCTAssertFalse(board.canPlace(piece: dot, atOriginRow: 0, originCol: 8))
    }

    func testSingleRowClear() {
        var board = Board()
        let line4 = Piece(shape: .line4H, colorIndex: 1)

        // Place two 4-horizontal lines in row 0 to complete all 8 cells
        board.place(piece: line4, atOriginRow: 0, originCol: 0)
        let secondResult = board.place(piece: line4, atOriginRow: 0, originCol: 4)

        XCTAssertNotNil(secondResult)
        XCTAssertEqual(secondResult?.clearedRows, [0])
        XCTAssertEqual(secondResult?.clearedCols.count, 0)
        XCTAssertEqual(secondResult?.linesClearedCount, 1)

        // Row 0 should now be cleared
        for c in 0..<8 {
            XCTAssertFalse(board.isOccupied(row: 0, col: c), "Cell (0, \(c)) should have been cleared")
        }
    }

    func testSingleColumnClear() {
        var board = Board()
        let line4V = Piece(shape: .line4V, colorIndex: 2)

        // Place two 4-vertical lines in column 3 to complete all 8 cells
        board.place(piece: line4V, atOriginRow: 0, originCol: 3)
        let secondResult = board.place(piece: line4V, atOriginRow: 4, originCol: 3)

        XCTAssertNotNil(secondResult)
        XCTAssertEqual(secondResult?.clearedRows.count, 0)
        XCTAssertEqual(secondResult?.clearedCols, [3])
        XCTAssertEqual(secondResult?.linesClearedCount, 1)

        // Column 3 should now be cleared
        for r in 0..<8 {
            XCTAssertFalse(board.isOccupied(row: r, col: 3), "Cell (\(r), 3) should have been cleared")
        }
    }

    func testCrossSimultaneousClear() {
        var board = Board()
        let dot = Piece(shape: .dot1x1, colorIndex: 0)

        // Fill row 4 except at (4, 4)
        for c in 0..<8 where c != 4 {
            board.place(piece: dot, atOriginRow: 4, originCol: c)
        }

        // Fill col 4 except at (4, 4)
        for r in 0..<8 where r != 4 {
            board.place(piece: dot, atOriginRow: r, originCol: 4)
        }

        // Now place final dot at intersection (4, 4)
        let crossResult = board.place(piece: dot, atOriginRow: 4, originCol: 4)

        XCTAssertNotNil(crossResult)
        XCTAssertEqual(crossResult?.clearedRows, [4])
        XCTAssertEqual(crossResult?.clearedCols, [4])
        XCTAssertEqual(crossResult?.linesClearedCount, 2)
        XCTAssertFalse(board.isOccupied(row: 4, col: 4))
    }

    func testComboIncrementsAndResets() {
        var scoreManager = ScoreManager(initialHighScore: 0)
        let line4 = Piece(shape: .line4H, colorIndex: 1)

        // Empty clear result (0 lines cleared)
        let nonClearResult = ClearResult(clearedRows: [], clearedCols: [], clearedCoordinates: [])
        let step1 = scoreManager.processPlacement(piece: line4, clearResult: nonClearResult)
        XCTAssertEqual(step1.currentCombo, 0)
        XCTAssertEqual(step1.placementPoints, 4)
        XCTAssertEqual(step1.totalAddedPoints, 4)

        // Clear result (1 line cleared)
        let clear1 = ClearResult(clearedRows: [0], clearedCols: [], clearedCoordinates: [])
        let step2 = scoreManager.processPlacement(piece: line4, clearResult: clear1)
        XCTAssertEqual(step2.currentCombo, 1)

        // Consecutive clear result (1 line cleared) -> Combo 2
        let clear2 = ClearResult(clearedRows: [1], clearedCols: [], clearedCoordinates: [])
        let step3 = scoreManager.processPlacement(piece: line4, clearResult: clear2)
        XCTAssertEqual(step3.currentCombo, 2)
        XCTAssertEqual(step3.comboBonusPoints, 2 * 25)
        XCTAssertEqual(step3.praise, .cool)

        // Next placement does not clear lines -> Combo resets to 0
        let step4 = scoreManager.processPlacement(piece: line4, clearResult: nonClearResult)
        XCTAssertEqual(step4.currentCombo, 0)
    }

    func testPieceGeneratorSolvabilityGuarantee() {
        let generator = PieceGenerator()
        var board = Board()

        // Test over 50 simulated batches on varied board configurations
        for _ in 0..<50 {
            let batch = generator.generateBatch(for: board)
            XCTAssertEqual(batch.count, 3)

            let hasPlayable = batch.contains { board.canPlaceAnywhere(piece: $0) }
            XCTAssertTrue(hasPlayable, "At least one piece in batch must be playable")
        }
    }

    func testThemesAreAllPresentAndDistinct() {
        let themes = ThemeRegistry.allThemes
        XCTAssertEqual(themes.count, 5)

        let ids = Set(themes.map(\.id))
        XCTAssertEqual(ids.count, 5, "Every theme must have a unique identifier")

        for theme in themes {
            XCTAssertFalse(theme.tilePalette.isEmpty, "Theme \(theme.name) must have a non-empty palette")
            XCTAssertEqual(theme.tilePalette.count, 7, "Theme \(theme.name) should contain 7 palette colors")
        }
    }
}
