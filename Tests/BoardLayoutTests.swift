import XCTest
@testable import BlockBlastLib

final class BoardLayoutTests: XCTestCase {

    func testPieceBounds() {
        let dot = Piece(shape: .dot1x1, colorIndex: 0)
        XCTAssertEqual(dot.bounds.width, 1)
        XCTAssertEqual(dot.bounds.height, 1)
        XCTAssertEqual(dot.bounds.minRow, 0)
        XCTAssertEqual(dot.bounds.maxRow, 0)
        XCTAssertEqual(dot.bounds.minCol, 0)
        XCTAssertEqual(dot.bounds.maxCol, 0)

        let line5H = Piece(shape: .line5H, colorIndex: 1)
        XCTAssertEqual(line5H.bounds.width, 5)
        XCTAssertEqual(line5H.bounds.height, 1)
        XCTAssertEqual(line5H.bounds.maxCol, 4)

        let square3x3 = Piece(shape: .square3x3, colorIndex: 2)
        XCTAssertEqual(square3x3.bounds.width, 3)
        XCTAssertEqual(square3x3.bounds.height, 3)

        let corner3x3_BR = Piece(shape: .corner3x3_BR, colorIndex: 3)
        XCTAssertEqual(corner3x3_BR.bounds.width, 3)
        XCTAssertEqual(corner3x3_BR.bounds.height, 3)
    }

    func testSearchRangesAtCenter() {
        let ranges = BoardLayout.placementSearchRanges(
            centerRow: 4,
            centerCol: 4,
            searchRadius: 2,
            gridSize: 8
        )
        XCTAssertNotNil(ranges)
        XCTAssertEqual(ranges?.rows, 2...6)
        XCTAssertEqual(ranges?.cols, 2...6)
    }

    func testSearchRangesAtCornersClamped() {
        let tl = BoardLayout.placementSearchRanges(
            centerRow: 0,
            centerCol: 0,
            searchRadius: 3,
            gridSize: 8
        )
        XCTAssertNotNil(tl)
        XCTAssertEqual(tl?.rows, 0...3)
        XCTAssertEqual(tl?.cols, 0...3)

        let br = BoardLayout.placementSearchRanges(
            centerRow: 7,
            centerCol: 7,
            searchRadius: 3,
            gridSize: 8
        )
        XCTAssertNotNil(br)
        XCTAssertEqual(br?.rows, 4...7)
        XCTAssertEqual(br?.cols, 4...7)
    }

    func testSearchRangesOffGridDoesNotCrash() {
        // Drag way above the grid
        let farAbove = BoardLayout.placementSearchRanges(
            centerRow: -50,
            centerCol: 4,
            searchRadius: 3,
            gridSize: 8
        )
        XCTAssertNil(farAbove)

        // Drag way below the grid
        let farBelow = BoardLayout.placementSearchRanges(
            centerRow: 999,
            centerCol: 4,
            searchRadius: 3,
            gridSize: 8
        )
        XCTAssertNil(farBelow)

        // Drag way left
        let farLeft = BoardLayout.placementSearchRanges(
            centerRow: 4,
            centerCol: -50,
            searchRadius: 3,
            gridSize: 8
        )
        XCTAssertNil(farLeft)

        // Drag way right
        let farRight = BoardLayout.placementSearchRanges(
            centerRow: 4,
            centerCol: 999,
            searchRadius: 3,
            gridSize: 8
        )
        XCTAssertNil(farRight)
    }

    func testAdaptiveLiftOffset() {
        let base: CGFloat = 48.0

        // Well below top: gets full lift
        XCTAssertEqual(BoardLayout.adaptiveLiftOffset(fingerGridY: 200, baseOffset: base), base)
        XCTAssertEqual(BoardLayout.adaptiveLiftOffset(fingerGridY: 48, baseOffset: base), base)

        // Within top band: tapers linearly to finger position
        XCTAssertEqual(BoardLayout.adaptiveLiftOffset(fingerGridY: 20, baseOffset: base), 20)
        XCTAssertEqual(BoardLayout.adaptiveLiftOffset(fingerGridY: 5, baseOffset: base), 5)

        // At top edge: zero lift
        XCTAssertEqual(BoardLayout.adaptiveLiftOffset(fingerGridY: 0, baseOffset: base), 0)

        // Above top edge: clamps to zero
        XCTAssertEqual(BoardLayout.adaptiveLiftOffset(fingerGridY: -30, baseOffset: base), 0)

        // Targeting point y - lift never crosses above grid (>= 0) for on-grid finger
        for y in stride(from: CGFloat(0), through: 400, by: 4) {
            let lift = BoardLayout.adaptiveLiftOffset(fingerGridY: y, baseOffset: base)
            XCTAssertGreaterThanOrEqual(lift, 0)
            XCTAssertLessThanOrEqual(lift, base)
            XCTAssertGreaterThanOrEqual(y - lift, 0)
        }
    }

    func testBlockCenterCalculation() {
        let dot = Piece(shape: .dot1x1, colorIndex: 0)
        let center00 = BoardLayout.blockCenter(
            for: dot,
            atOriginRow: 0,
            originCol: 0,
            cellSize: 40,
            cellSpacing: 4
        )
        XCTAssertEqual(center00.x, 20)
        XCTAssertEqual(center00.y, 20)

        let center12 = BoardLayout.blockCenter(
            for: dot,
            atOriginRow: 1,
            originCol: 2,
            cellSize: 40,
            cellSpacing: 4
        )
        // col 2: 2 * 44 + 20 = 108; row 1: 1 * 44 + 20 = 64
        XCTAssertEqual(center12.x, 108)
        XCTAssertEqual(center12.y, 64)
    }

    func testFindOptimalPlacementSnapsToNearestCell() {
        let board = Board()
        let dot = Piece(shape: .dot1x1, colorIndex: 0)

        // Target cell (2, 3): center is x = 3 * 44 + 20 = 152, y = 2 * 44 + 20 = 108
        let nearPoint = CGPoint(x: 154, y: 106) // slightly off-center
        let placement = BoardLayout.findOptimalPlacement(
            for: dot,
            nearPoint: nearPoint,
            cellSize: 40,
            cellSpacing: 4,
            gridSize: 8,
            maxDistance: 260,
            canPlace: { p, r, c in board.canPlace(piece: p, atOriginRow: r, originCol: c) }
        )

        XCTAssertNotNil(placement)
        XCTAssertEqual(placement?.row, 2)
        XCTAssertEqual(placement?.col, 3)
    }

    func testFindOptimalPlacementReturnsNilWhenTooFar() {
        let board = Board()
        let dot = Piece(shape: .dot1x1, colorIndex: 0)

        // Point extremely far off
        let farPoint = CGPoint(x: 1500, y: 1500)
        let placement = BoardLayout.findOptimalPlacement(
            for: dot,
            nearPoint: farPoint,
            cellSize: 40,
            cellSpacing: 4,
            gridSize: 8,
            maxDistance: 260,
            canPlace: { p, r, c in board.canPlace(piece: p, atOriginRow: r, originCol: c) }
        )

        XCTAssertNil(placement)
    }
}
