import SwiftUI

public struct DraggablePieceView: View {
    public let piece: Piece
    public let index: Int
    @ObservedObject var gameState: GameState
    public let slotSize: CGFloat

    public init(
        piece: Piece,
        index: Int,
        gameState: GameState,
        slotSize: CGFloat
    ) {
        self.piece = piece
        self.index = index
        self.gameState = gameState
        self.slotSize = slotSize
    }

    public var body: some View {
        let isBeingDragged = gameState.activeDrag?.pieceIndex == index
        let baseColor = gameState.activeTheme.tileColor(for: piece.colorIndex).swiftUIColor
        let bounds = piece.bounds
        let blockW = CGFloat(bounds.width)
        let blockH = CGFloat(bounds.height)

        // Fit piece within 74% of card slot, with max cell size of 26pt so 1x1 isn't gigantic
        let availableWidth = slotSize * 0.74
        let availableHeight = slotSize * 0.74
        let cellSpacing: CGFloat = 2.5
        let rawCellSize = min(
            (availableWidth - max(0, blockW - 1) * cellSpacing) / blockW,
            (availableHeight - max(0, blockH - 1) * cellSpacing) / blockH
        )
        let trayCellSize = max(10.0, min(rawCellSize, 26.0))
        let totalW = blockW * trayCellSize + max(0, blockW - 1) * cellSpacing
        let totalH = blockH * trayCellSize + max(0, blockH - 1) * cellSpacing

        ZStack {
            // Card container background
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(gameState.activeTheme.boardBackground.swiftUIColor.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor, lineWidth: 1.2)
                )

            // Piece Grid - precisely centered inside card
            ZStack {
                ForEach(piece.coordinates, id: \.self) { coord in
                    let relCol = CGFloat(coord.col - bounds.minCol)
                    let relRow = CGFloat(coord.row - bounds.minRow)
                    let cellX = relCol * (trayCellSize + cellSpacing) + trayCellSize / 2.0 - totalW / 2.0
                    let cellY = relRow * (trayCellSize + cellSpacing) + trayCellSize / 2.0 - totalH / 2.0

                    RoundedRectangle(cornerRadius: max(3.0, trayCellSize * 0.22), style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [baseColor.opacity(0.85), baseColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: max(3.0, trayCellSize * 0.22), style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1.0)
                        )
                        .frame(width: trayCellSize, height: trayCellSize)
                        .offset(x: cellX, y: cellY)
                }
            }
            .frame(width: totalW, height: totalH)
            .opacity(isBeingDragged ? 0.2 : 1.0)
        }
        .frame(width: slotSize, height: slotSize)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if gameState.activeDrag?.pieceIndex != index {
                        gameState.startDrag(index: index, piece: piece, location: value.location)
                    } else {
                        gameState.updateDrag(location: value.location)
                    }
                }
                .onEnded { _ in
                    gameState.endDrag()
                }
        )
    }
}
