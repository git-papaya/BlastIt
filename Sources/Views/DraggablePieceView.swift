import SwiftUI

public struct DraggablePieceView: View {
    public let piece: Piece
    public let index: Int
    @ObservedObject var gameState: GameState
    public let slotSize: CGFloat

    private var maxDimension: Int {
        max(piece.width, piece.height)
    }

    private var trayCellSize: CGFloat {
        switch maxDimension {
        case 1: return 36.0
        case 2: return 28.0
        case 3: return 22.0
        case 4: return 17.5
        default: return 14.0
        }
    }

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
        let totalW = CGFloat(piece.width) * trayCellSize + CGFloat(piece.width - 1) * 2.5
        let totalH = CGFloat(piece.height) * trayCellSize + CGFloat(piece.height - 1) * 2.5

        ZStack {
            // Card container background
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(gameState.activeTheme.boardBackground.swiftUIColor.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor, lineWidth: 1.2)
                )

            // Piece Grid - precisely centered inside card by ZStack
            VStack(spacing: 2.5) {
                ForEach(0..<piece.height, id: \.self) { r in
                    HStack(spacing: 2.5) {
                        ForEach(0..<piece.width, id: \.self) { c in
                            if piece.coordinates.contains(Coordinate(row: r, col: c)) {
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
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: trayCellSize, height: trayCellSize)
                            }
                        }
                    }
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
                    }
                    gameState.updateDrag(location: value.location)
                }
                .onEnded { _ in
                    gameState.endDrag()
                }
        )
    }
}
