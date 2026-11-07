import SwiftUI

public struct DraggablePieceView: View {
    public let piece: Piece
    public let index: Int
    @ObservedObject var gameState: GameState
    public let gridGeometry: GridGeometry
    public let slotSize: CGFloat

    private var maxDimension: Int {
        max(piece.width, piece.height)
    }

    private var trayCellSize: CGFloat {
        let available = slotSize - 20.0
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
        let isBeingDragged = gameState.activeDrag?.pieceIndex == index
        let baseColor = gameState.activeTheme.tileColor(for: piece.colorIndex).swiftUIColor
        let step = trayCellSize + 2.0

        ZStack {
            // Invisible hit box filling the entire slot
            Color.clear
                .contentShape(Rectangle())

            // Symmetrically centered piece tiles
            ForEach(piece.coordinates, id: \.self) { coord in
                let cellX = (CGFloat(coord.col) - CGFloat(piece.width - 1) / 2.0) * step
                let cellY = (CGFloat(coord.row) - CGFloat(piece.height - 1) / 2.0) * step

                RoundedRectangle(cornerRadius: max(3, trayCellSize * 0.22), style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [baseColor.opacity(0.85), baseColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: max(3, trayCellSize * 0.22), style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1.0)
                    )
                    .frame(width: trayCellSize, height: trayCellSize)
                    .offset(x: cellX, y: cellY)
            }
        }
        .frame(width: slotSize, height: slotSize)
        .opacity(isBeingDragged ? 0.2 : 1.0)
        .gesture(
            DragGesture(coordinateSpace: .named("GameCoordinateSpace"))
                .onChanged { value in
                    if gameState.activeDrag?.pieceIndex != index {
                        gameState.startDrag(index: index, piece: piece, location: value.location)
                    }
                    gameState.updateDrag(location: value.location, gridGeometry: gridGeometry)
                }
                .onEnded { _ in
                    gameState.endDrag()
                }
        )
    }
}
