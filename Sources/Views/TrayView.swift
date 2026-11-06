import SwiftUI

public struct TrayView: View {
    @ObservedObject var gameState: GameState
    public let gridGeometry: GridGeometry

    public init(gameState: GameState, gridGeometry: GridGeometry) {
        self.gameState = gameState
        self.gridGeometry = gridGeometry
    }

    public var body: some View {
        GeometryReader { geo in
            let totalAvailableW = geo.size.width - 32.0 // 16pt margin on left and right
            let slotSize = max(70.0, min(96.0, (totalAvailableW - 32.0) / 3.0))

            HStack(spacing: 16) {
                ForEach(0..<gameState.trayPieces.count, id: \.self) { index in
                    ZStack {
                        // Slot container background
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(gameState.activeTheme.boardBackground.swiftUIColor.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor, lineWidth: 1.2)
                            )
                            .frame(width: slotSize, height: slotSize)

                        // Draggable piece if present
                        if let piece = gameState.trayPieces[index] {
                            DraggablePieceView(
                                piece: piece,
                                index: index,
                                gameState: gameState,
                                gridGeometry: gridGeometry,
                                slotSize: slotSize
                            )
                        }
                    }
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(height: 104)
        .padding(.horizontal, 16)
    }
}
