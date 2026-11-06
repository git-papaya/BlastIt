import SwiftUI

public struct GameOverOverlayView: View {
    @ObservedObject var gameState: GameState

    public init(gameState: GameState) {
        self.gameState = gameState
    }

    public var body: some View {
        ZStack {
            // Blurred dark backdrop
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                Text("GAME OVER")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)

                // Stats Card
                VStack(spacing: 16) {
                    if gameState.score > 0 && gameState.score >= gameState.highScore {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("NEW HIGH SCORE!")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.yellow.opacity(0.2)))
                    }

                    // Score
                    VStack(spacing: 4) {
                        Text("FINAL SCORE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                        Text("\(gameState.score)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)
                    }

                    Divider()
                        .background(gameState.activeTheme.gridLine.swiftUIColor)

                    // Best Score & Combos Row
                    HStack(spacing: 36) {
                        VStack(spacing: 2) {
                            Text("BEST")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                            Text("\(gameState.highScore)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)
                        }

                        VStack(spacing: 2) {
                            Text("STREAK")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                            Text("\(gameState.comboCount)x")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 300)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(gameState.activeTheme.boardBackground.swiftUIColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(gameState.activeTheme.gridLine.swiftUIColor, lineWidth: 1.5)
                        )
                )

                // Instant Play Again Button (Zero Ads!)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        gameState.startNewGame()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))
                        Text("Play Again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 260)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
            .padding(24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}
