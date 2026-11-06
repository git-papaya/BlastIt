import SwiftUI

public struct DraggablePieceView: View {
    public let piece: Piece
    public let index: Int
    @ObservedObject var gameState: GameState
    public let boardFrame: CGRect
    public let boardCellSize: CGFloat

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var currentHoverCell: (row: Int, col: Int)? = nil

    private let verticalTouchOffset: CGFloat = -75.0
    private let trayCellSize: CGFloat = 22.0

    public init(
        piece: Piece,
        index: Int,
        gameState: GameState,
        boardFrame: CGRect,
        boardCellSize: CGFloat
    ) {
        self.piece = piece
        self.index = index
        self.gameState = gameState
        self.boardFrame = boardFrame
        self.boardCellSize = boardCellSize
    }

    public var body: some View {
        GeometryReader { geo in
            let activeCellSize = isDragging ? boardCellSize : trayCellSize
            let pieceView = pieceShapeView(cellSize: activeCellSize)

            pieceView
                .scaleEffect(isDragging ? 1.0 : 0.85)
                .shadow(
                    color: Color.black.opacity(isDragging ? 0.35 : 0.0),
                    radius: isDragging ? 12 : 0,
                    x: 0,
                    y: isDragging ? 10 : 0
                )
                .offset(x: dragOffset.width, y: dragOffset.height + (isDragging ? verticalTouchOffset : 0))
                .gesture(
                    DragGesture(coordinateSpace: .named("GameCoordinateSpace"))
                        .onChanged { value in
                            handleDragChanged(value: value, trayPieceCenter: geo.frame(in: .named("GameCoordinateSpace")).center)
                        }
                        .onEnded { value in
                            handleDragEnded(value: value)
                        }
                )
                .zIndex(isDragging ? 999 : 1)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(width: 90, height: 90)
    }

    @ViewBuilder
    private func pieceShapeView(cellSize: CGFloat) -> some View {
        let baseColor = gameState.activeTheme.tileColor(for: piece.colorIndex).swiftUIColor
        let totalW = CGFloat(piece.width) * (cellSize + 2)
        let totalH = CGFloat(piece.height) * (cellSize + 2)

        ZStack(alignment: .topLeading) {
            ForEach(piece.coordinates, id: \.self) { coord in
                RoundedRectangle(cornerRadius: max(3, cellSize * 0.22), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [baseColor.opacity(0.85), baseColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: max(3, cellSize * 0.22), style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1.0)
                    )
                    .frame(width: cellSize, height: cellSize)
                    .offset(
                        x: CGFloat(coord.col) * (cellSize + 2),
                        y: CGFloat(coord.row) * (cellSize + 2)
                    )
            }
        }
        .frame(width: totalW, height: totalH)
    }

    private func handleDragChanged(value: DragGesture.Value, trayPieceCenter: CGPoint) {
        if !isDragging {
            isDragging = true
            HapticManager.shared.pieceHover()
        }

        dragOffset = value.translation

        // Calculate floating top-left corner of the piece in the global coordinate space
        let floatingPieceCenterX = trayPieceCenter.x + value.translation.width
        let floatingPieceCenterY = trayPieceCenter.y + value.translation.height + verticalTouchOffset

        let piecePixelWidth = CGFloat(piece.width) * (boardCellSize + 4)
        let piecePixelHeight = CGFloat(piece.height) * (boardCellSize + 4)

        let floatingOriginX = floatingPieceCenterX - (piecePixelWidth / 2.0)
        let floatingOriginY = floatingPieceCenterY - (piecePixelHeight / 2.0)

        // Calculate target board row/col
        let relativeX = floatingOriginX - boardFrame.minX - 8.0 // account for board inner padding
        let relativeY = floatingOriginY - boardFrame.minY - 8.0

        let colStep = boardCellSize + 4.0
        let rowStep = boardCellSize + 4.0

        let targetCol = Int(round(relativeX / colStep))
        let targetRow = Int(round(relativeY / rowStep))

        if targetRow >= 0 && targetRow <= (Board.size - piece.height) &&
           targetCol >= 0 && targetCol <= (Board.size - piece.width) {
            if gameState.board.canPlace(piece: piece, atOriginRow: targetRow, originCol: targetCol) {
                if currentHoverCell?.row != targetRow || currentHoverCell?.col != targetCol {
                    currentHoverCell = (targetRow, targetCol)
                    HapticManager.shared.pieceHover()
                }
                gameState.setGhostPlacement(originRow: targetRow, originCol: targetCol, piece: piece)
                return
            }
        }

        currentHoverCell = nil
        gameState.setGhostPlacement(originRow: nil, originCol: nil, piece: nil)
    }

    private func handleDragEnded(value: DragGesture.Value) {
        if let target = currentHoverCell {
            let placed = gameState.placePiece(index: index, atOriginRow: target.row, originCol: target.col)
            if placed {
                dragOffset = .zero
                isDragging = false
                currentHoverCell = nil
                return
            }
        }

        // Snap back to tray with spring animation
        withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
            dragOffset = .zero
            isDragging = false
            currentHoverCell = nil
            gameState.setGhostPlacement(originRow: nil, originCol: nil, piece: nil)
        }
    }
}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
