import SwiftUI

public struct ThemeSelectionSheet: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    public init(gameState: GameState) {
        self.gameState = gameState
    }

    public var body: some View {
        NavigationView {
            ZStack {
                gameState.activeTheme.backgroundTop.swiftUIColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Settings Header (Sound & Haptics)
                        HStack(spacing: 12) {
                            toggleCard(
                                title: "Sound FX",
                                iconName: PersistenceManager.shared.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                                isOn: PersistenceManager.shared.isSoundEnabled,
                                action: { gameState.toggleSound() }
                            )

                            toggleCard(
                                title: "Haptics",
                                iconName: PersistenceManager.shared.isHapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash",
                                isOn: PersistenceManager.shared.isHapticsEnabled,
                                action: { gameState.toggleHaptics() }
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)

                        // Section Title
                        HStack {
                            Text("THEMES (ALL UNLOCKED)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Themes List
                        VStack(spacing: 14) {
                            ForEach(ThemeRegistry.allThemes) { theme in
                                themeRow(theme: theme)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Game Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(gameState.activeTheme.accent.swiftUIColor)
                }
            }
        }
    }

    @ViewBuilder
    private func toggleCard(title: String, iconName: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isOn ? gameState.activeTheme.accent.swiftUIColor : .gray)

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)

                Spacer()

                Circle()
                    .fill(isOn ? Color.green : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(gameState.activeTheme.cardBackground.swiftUIColor)
            )
        }
    }

    @ViewBuilder
    private func themeRow(theme: GameTheme) -> some View {
        let isSelected = gameState.activeTheme.id == theme.id

        Button(action: {
            gameState.setTheme(theme)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: theme.iconName)
                        .foregroundColor(theme.accent.swiftUIColor)

                    Text(theme.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(gameState.activeTheme.textPrimary.swiftUIColor)

                    Spacer()

                    if isSelected {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("ACTIVE")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("APPLY")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)
                    }
                }

                Text(theme.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(gameState.activeTheme.textSecondary.swiftUIColor)

                // Swatch Row
                HStack(spacing: 8) {
                    ForEach(0..<min(6, theme.tilePalette.count), id: \.self) { i in
                        Circle()
                            .fill(theme.tilePalette[i].swiftUIColor)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(gameState.activeTheme.cardBackground.swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                isSelected ? theme.accent.swiftUIColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
    }
}
