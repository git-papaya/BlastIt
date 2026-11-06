import SwiftUI

public struct ScoreHeaderView: View {
    @ObservedObject var gameState: GameState
    @Binding var showThemeSheet: Bool

    public init(gameState: GameState, showThemeSheet: Binding<Bool>) {
        self.gameState = gameState
        self._showThemeSheet = showThemeSheet
    }

    public var body: some View {
        HStack(alignment: .center) {
            // Current Score
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                
                Text("\(gameState.score)")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: gameState.score)
            }

            Spacer()

            // Combo Streak Badge (if active)
            if gameState.comboCount > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .imageScale(.small)
                    Text("\(gameState.comboCount)x COMBO")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: gameState.comboCount)
            }

            Spacer()

            // High Score
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 11))
                        .foregroundColor(gameState.activeTheme.accent.swiftUIColor)
                    Text("BEST")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                }
                
                Text("\(gameState.highScore)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)
            }

            // Theme Switcher Button
            Button(action: {
                showThemeSheet = true
            }) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(gameState.activeTheme.cardBackground.swiftUIColor)
                    )
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}
