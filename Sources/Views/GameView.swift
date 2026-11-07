import SwiftUI

public struct GameView: View {
    @StateObject private var gameState = GameState()
    @State private var showThemeSheet: Bool = false

    public init() {}

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

            // Main Content with Safe Area Spacing
            VStack(spacing: 0) {
                // Header (Score, Best, Theme Trigger)
                ScoreHeaderView(gameState: gameState, showThemeSheet: $showThemeSheet)
                    .padding(.top, 44)

                Spacer()

                // Center 8x8 Board
                BoardView(gameState: gameState)
                    .padding(.horizontal, 16)

                Spacer()

                // Bottom Piece Tray
                TrayView(gameState: gameState)
                    .padding(.bottom, 24)
            }

            // Root-Level Dragging Piece Overlay
            if let drag = gameState.activeDrag {
                FloatingPieceView(
                    piece: drag.piece,
                    visualCenter: drag.visualCenter,
                    cellSize: gameState.boardCellSize > 0 ? gameState.boardCellSize : 38.0,
                    cellSpacing: 4.0,
                    theme: gameState.activeTheme
                )
                .zIndex(9999)
            }

            // Game Over Modal Overlay
            if gameState.isGameOver {
                GameOverOverlayView(gameState: gameState)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showThemeSheet) {
            ThemeSelectionSheet(gameState: gameState)
        }
    }
}
