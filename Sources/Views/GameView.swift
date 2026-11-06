import SwiftUI

public struct GameView: View {
    @StateObject private var gameState = GameState()
    @State private var gridGeometry: GridGeometry = GridGeometry()
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

            VStack(spacing: 0) {
                // Header (Score, Best, Theme Trigger)
                ScoreHeaderView(gameState: gameState, showThemeSheet: $showThemeSheet)
                    .padding(.top, 8)

                Spacer()

                // Center 8x8 Board
                BoardView(gameState: gameState) { newGeometry in
                    gridGeometry = newGeometry
                }
                .padding(.horizontal, 16)

                Spacer()

                // Bottom Piece Tray (zIndex elevated for drag clearance)
                TrayView(
                    gameState: gameState,
                    gridGeometry: gridGeometry
                )
                .zIndex(100)
                .padding(.bottom, 20)
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
