import SwiftUI

public struct TrayView: View {
    @ObservedObject var gameState: GameState

    private let slotSize: CGFloat = 94.0
    private let slotSpacing: CGFloat = 12.0

    public init(gameState: GameState) {
        self.gameState = gameState
    }

    public var body: some View {
        HStack(spacing: slotSpacing) {
            ForEach(0..<gameState.trayPieces.count, id: \.self) { index in
                if let piece = gameState.trayPieces[index] {
                    DraggablePieceView(
                        piece: piece,
                        index: index,
                        gameState: gameState,
                        slotSize: slotSize
                    )
                } else {
                    // Empty slot placeholder
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(gameState.activeTheme.boardBackground.swiftUIColor.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor.opacity(0.35), lineWidth: 1.0)
                        )
                        .frame(width: slotSize, height: slotSize)
                }
            }
        }
        .frame(height: 104)
        .padding(.horizontal, 16)
    }
}
