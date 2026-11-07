import SwiftUI

public struct TrayView: View {
    @ObservedObject var gameState: GameState

    public init(gameState: GameState) {
        self.gameState = gameState
    }

    public var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<gameState.trayPieces.count, id: \.self) { index in
                if let piece = gameState.trayPieces[index] {
                    DraggablePieceView(
                        piece: piece,
                        index: index,
                        gameState: gameState,
                        slotSize: 92.0
                    )
                } else {
                    // Empty slot placeholder
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(gameState.activeTheme.boardBackground.swiftUIColor.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor.opacity(0.4), lineWidth: 1.0)
                        )
                        .frame(width: 92.0, height: 92.0)
                }
            }
        }
        .frame(height: 96)
        .padding(.horizontal, 16)
    }
}
