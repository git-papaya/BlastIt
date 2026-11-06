import SwiftUI

public struct TrayView: View {
    @ObservedObject var gameState: GameState
    public let boardFrame: CGRect
    public let boardCellSize: CGFloat

    public init(gameState: GameState, boardFrame: CGRect, boardCellSize: CGFloat) {
        self.gameState = gameState
        self.boardFrame = boardFrame
        self.boardCellSize = boardCellSize
    }

    public var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<gameState.trayPieces.count, id: \.self) { index in
                ZStack {
                    // Tray slot background placeholder
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(gameState.activeTheme.boardBackground.swiftUIColor.opacity(0.35))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor, lineWidth: 1)
                        )
                        .frame(width: 100, height: 100)

                    // Active draggable piece if present
                    if let piece = gameState.trayPieces[index] {
                        DraggablePieceView(
                            piece: piece,
                            index: index,
                            gameState: gameState,
                            boardFrame: boardFrame,
                            boardCellSize: boardCellSize
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
