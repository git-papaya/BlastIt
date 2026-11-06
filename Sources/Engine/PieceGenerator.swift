import Foundation

public struct PieceGenerator {
    public static let paletteCount = 7

    public init() {}

    /// Generates a batch of 3 pieces tailored to the current board state to guarantee solvability and engagement.
    public func generateBatch(for board: Board) -> [Piece] {
        var batch: [Piece] = []
        var simulatedBoard = board

        for i in 0..<3 {
            let shape = selectShape(for: simulatedBoard, pieceIndexInBatch: i)
            let colorIndex = Int.random(in: 0..<Self.paletteCount)
            let piece = Piece(shape: shape, colorIndex: colorIndex)
            batch.append(piece)

            // To ensure the next pieces in the batch remain playable, find the first valid position
            // and simulate placing it so simulatedBoard reflects the subsequent state.
            if let firstOrigin = findFirstValidOrigin(for: piece, on: simulatedBoard) {
                if let (nextBoard, _) = simulatedBoard.simulatingPlacement(piece: piece, atOriginRow: firstOrigin.row, originCol: firstOrigin.col) {
                    simulatedBoard = nextBoard
                }
            }
        }

        // Final safety check: At least one piece in the batch must be valid on the original board
        let hasPlayablePiece = batch.contains { board.canPlaceAnywhere(piece: $0) }
        if !hasPlayablePiece {
            // Replace the last piece with a guaranteed playable shape (or single dot)
            let fallbackShape = findPlayableShape(on: board) ?? .dot1x1
            batch[2] = Piece(shape: fallbackShape, colorIndex: Int.random(in: 0..<Self.paletteCount))
        }

        return batch
    }

    private func selectShape(for board: Board, pieceIndexInBatch: Int) -> PieceShape {
        let vacancy = board.vacancyRatio
        let allShapes = PieceShape.allCases

        // Filter shapes that can actually fit on the board
        let playableShapes = allShapes.filter { shape in
            let tempPiece = Piece(shape: shape, colorIndex: 0)
            return board.canPlaceAnywhere(piece: tempPiece)
        }

        guard !playableShapes.isEmpty else {
            return .dot1x1
        }

        // Weighting strategy based on board tightness
        if vacancy < 0.25 {
            // Highly crowded: favor small 1-3 cell shapes to allow recovery
            let smallPlayable = playableShapes.filter { $0.coordinates.count <= 3 }
            if !smallPlayable.isEmpty {
                return smallPlayable.randomElement()!
            }
        } else if vacancy < 0.45 {
            // Moderately crowded: favor 1-4 cell shapes
            let mediumPlayable = playableShapes.filter { $0.coordinates.count <= 4 }
            if !mediumPlayable.isEmpty && Bool.random() {
                return mediumPlayable.randomElement()!
            }
        }

        // In first slot of batch, provide variety (could be large or small)
        if pieceIndexInBatch == 0 && vacancy > 0.5 {
            return playableShapes.randomElement()!
        }

        return playableShapes.randomElement()!
    }

    private func findPlayableShape(on board: Board) -> PieceShape? {
        let preferenceOrder: [PieceShape] = [
            .dot1x1,
            .line2H, .line2V,
            .line3H, .line3V,
            .square2x2,
            .corner2x2_TL, .corner2x2_TR, .corner2x2_BL, .corner2x2_BR
        ]

        for shape in preferenceOrder {
            let piece = Piece(shape: shape, colorIndex: 0)
            if board.canPlaceAnywhere(piece: piece) {
                return shape
            }
        }

        return PieceShape.allCases.first { shape in
            board.canPlaceAnywhere(piece: Piece(shape: shape, colorIndex: 0))
        }
    }

    private func findFirstValidOrigin(for piece: Piece, on board: Board) -> Coordinate? {
        let maxRow = Board.size - piece.height
        let maxCol = Board.size - piece.width
        guard maxRow >= 0 && maxCol >= 0 else { return nil }

        for r in 0...maxRow {
            for c in 0...maxCol {
                if board.canPlace(piece: piece, atOriginRow: r, originCol: c) {
                    return Coordinate(row: r, col: c)
                }
            }
        }
        return nil
    }
}
