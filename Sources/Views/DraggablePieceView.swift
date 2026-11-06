import SwiftUI

public struct DraggablePieceView: View {
    public let piece: Piece
    public let index: Int
    @ObservedObject var gameState: GameState
    public let gridGeometry: GridGeometry
    public let slotSize: CGFloat

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var currentHoverCell: (row: Int, col: Int)? = nil

    private let verticalTouchOffset: CGFloat = -70.0

    private var maxDimension: Int {
        max(piece.width, piece.height)
    }

    private var trayCellSize: CGFloat {
        let available = slotSize - 22.0
        let spacingTotal = CGFloat(maxDimension - 1) * 2.0
        let calculated = (available - spacingTotal) / CGFloat(maxDimension)
        return max(10.0, min(20.0, calculated))
    }

    public init(
        piece: Piece,
        index: Int,
        gameState: GameState,
        gridGeometry: GridGeometry,
        slotSize: CGFloat
    ) {
        self.piece = piece
        self.index = index
        self.gameState = gameState
        self.gridGeometry = gridGeometry
        self.slotSize = slotSize
    }

    public var body: some View {
        GeometryReader { geo in
            let activeCellSize = isDragging ? (gridGeometry.cellSize > 0 ? gridGeometry.cellSize : 38.0) : trayCellSize
            let activeSpacing: CGFloat = isDragging ? 4.0 : 2.0
            let pieceContent = pieceShapeView(cellSize: activeCellSize, spacing: activeSpacing)

            pieceContent
                .shadow(
                    color: Color.black.opacity(isDragging ? 0.4 : 0.0),
                    radius: isDragging ? 12 : 0,
                    x: 0,
                    y: isDragging ? 8 : 0
                )
                .offset(x: dragOffset.width, y: dragOffset.height + (isDragging ? verticalTouchOffset : 0))
                .gesture(
                    DragGesture(coordinateSpace: .named("GameCoordinateSpace"))
                        .onChanged { value in
                            let slotCenter = geo.frame(in: .named("GameCoordinateSpace")).center
                            handleDragChanged(value: value, slotCenter: slotCenter, activeCellSize: activeCellSize, activeSpacing: activeSpacing)
                        }
                        .onEnded { value in
                            handleDragEnded(value: value)
                        }
                )
                .zIndex(isDragging ? 999 : 1)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(width: slotSize, height: slotSize)
    }

    @ViewBuilder
    private func pieceShapeView(cellSize: CGFloat, spacing: CGFloat) -> some View {
        let baseColor = gameState.activeTheme.tileColor(for: piece.colorIndex).swiftUIColor
        let totalW = CGFloat(piece.width) * cellSize + CGFloat(piece.width - 1) * spacing
        let totalH = CGFloat(piece.height) * cellSize + CGFloat(piece.height - 1) * spacing

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
                        x: CGFloat(coord.col) * (cellSize + spacing),
                        y: CGFloat(coord.row) * (cellSize + spacing)
                    )
            }
        }
        .frame(width: totalW, height: totalH)
    }

    private func handleDragChanged(value: DragGesture.Value, slotCenter: CGPoint, activeCellSize: CGFloat, activeSpacing: CGFloat) {
        if !isDragging {
            isDragging = true
            HapticManager.shared.pieceHover()
        }

        dragOffset = value.translation

        // Calculate center of dragged piece in GameCoordinateSpace
        let pieceCenterX = slotCenter.x + value.translation.width
        let pieceCenterY = slotCenter.y + value.translation.height + verticalTouchOffset

        let cellStep = activeCellSize + activeSpacing

        // Center of the piece's top-left cell (Coordinate 0, 0)
        let cell0CenterX = pieceCenterX - (CGFloat(piece.width - 1) * cellStep / 2.0)
        let cell0CenterY = pieceCenterY - (CGFloat(piece.height - 1) * cellStep / 2.0)

        // Board row 0, col 0 cell center
        let board0CenterX = gridGeometry.frame.minX + (activeCellSize / 2.0)
        let board0CenterY = gridGeometry.frame.minY + (activeCellSize / 2.0)

        guard cellStep > 0 else { return }

        let targetCol = Int(round((cell0CenterX - board0CenterX) / cellStep))
        let targetRow = Int(round((cell0CenterY - board0CenterY) / cellStep))

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
