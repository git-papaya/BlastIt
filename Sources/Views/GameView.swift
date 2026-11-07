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

            SafeAreaContent(
                gameState: gameState,
                gridGeometry: $gridGeometry,
                showThemeSheet: $showThemeSheet
            )

            // Root-Level Dragging Piece Overlay
            if let drag = gameState.activeDrag {
                FloatingPieceView(
                    piece: drag.piece,
                    touchLocation: drag.touchLocation,
                    cellSize: gridGeometry.cellSize > 0 ? gridGeometry.cellSize : 38.0,
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

private struct SafeAreaContent: View {
    @ObservedObject var gameState: GameState
    @Binding var gridGeometry: GridGeometry
    @Binding var showThemeSheet: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header (Score, Best, Theme Trigger)
            ScoreHeaderView(gameState: gameState, showThemeSheet: $showThemeSheet)
                .padding(.top, 44) // Accommodate safe area / status bar

            Spacer()

            // Center 8x8 Board
            BoardView(gameState: gameState) { newGeometry in
                gridGeometry = newGeometry
            }
            .padding(.horizontal, 16)

            Spacer()

            // Bottom Piece Tray
            TrayView(
                gameState: gameState,
                gridGeometry: gridGeometry
            )
            .padding(.bottom, 24)
        }
    }
}
