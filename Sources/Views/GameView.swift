import SwiftUI

public struct GameView: View {
    @StateObject private var gameState = GameState()
    @State private var boardFrame: CGRect = .zero
    @State private var showThemeSheet: Bool = false

    public init() {}

    private var boardCellSize: CGFloat {
        let padding: CGFloat = 8.0
        let innerSize = boardFrame.width - (padding * 2.0)
        let spacingTotal = CGFloat(Board.size - 1) * 4.0
        return max(10, (innerSize - spacingTotal) / CGFloat(Board.size))
    }

    public var body: some View {
        ZStack {
            // Background Theme Gradient
            LinearGradient(
                colors: [
                    gameState.activeTheme.backgroundTop.swiftUIColor,
                    gameState.activeTheme.backgroundBottom.swiftUIColor
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Score, Best, Theme Trigger)
                ScoreHeaderView(gameState: gameState, showThemeSheet: $showThemeSheet)
                    .padding(.top, 8)

                Spacer()

                // Center 8x8 Board
                BoardView(gameState: gameState) { newFrame in
                    boardFrame = newFrame
                }
                .padding(.horizontal, 16)

                Spacer()

                // Bottom Piece Tray
                TrayView(
                    gameState: gameState,
                    boardFrame: boardFrame,
                    boardCellSize: boardCellSize
                )
                .padding(.bottom, 16)
            }

            // Game Over Modal Overlay
            if gameState.isGameOver {
                GameOverOverlayView(gameState: gameState)
            }
        }
        .coordinateSpace(name: "GameCoordinateSpace")
        .sheet(isPresented: $showThemeSheet) {
            ThemeSelectionSheet(gameState: gameState)
        }
    }
}
