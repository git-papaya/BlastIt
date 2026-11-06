# Block Blast - Native iOS Clone (Ad-Free & Fully Unlocked)

A high-performance native iOS clone of the popular puzzle game **Block Blast!** built with **Swift** and **SwiftUI** for iOS 16.0+.

This project features:
- **100% Ad-Free**: No video ads, no interstitial popups, zero microtransactions, and instant game restarts.
- **Everything Unlocked**: All 5 custom themes and audio experiences are unlocked from the start.
- **64-bit Bitboard Engine**: Fast piece collision testing and simultaneous row/column line clears.
- **Procedural Combo Audio**: Synthesized harmonic pentatonic chimes using `AVFoundation` with pitch-shifting combos ($C_5 \to C_7$), requiring zero external audio assets.
- **Haptic Feedback**: Dynamic tactile sensations via `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`.
- **Intelligent Solvability Bag**: Biased piece generator preventing unfair premature board lockouts.
- **Ergonomic Drag-and-Drop**: Touch offset (-75pt) so pieces hover visibly above the thumb with real-time snap-ghost preview.

---

## Project Structure

```
BlockBlast/
├── BlockBlast.xcodeproj/
│   └── project.pbxproj            # Standard Xcode project file (iOS 16.0+)
├── Package.swift                  # Swift Package Manager manifest
├── Resources/
│   ├── Info.plist                 # iOS application bundle configuration
│   └── Assets.xcassets/           # App icon & accent color sets
├── Sources/
│   ├── App/
│   │   └── BlockBlastApp.swift    # @main application entry point
│   ├── Engine/
│   │   ├── Board.swift            # 64-bit bitboard & row/column clear detector
│   │   ├── Piece.swift            # Polyomino definitions & coordinate math
│   │   ├── PieceGenerator.swift   # Solvability-guaranteed piece dealing
│   │   ├── ScoreManager.swift     # Score breakdown, multi-line & combo math
│   │   └── GameState.swift        # Central ObservableObject coordinator
│   ├── Audio/
│   │   ├── SoundManager.swift     # In-memory procedural WAV synthesis
│   │   └── HapticManager.swift    # iOS haptic engine integration
│   ├── Themes/
│   │   ├── Theme.swift            # Theme schema & RGB color abstractions
│   │   └── ThemeRegistry.swift    # 5 pre-configured unlocked themes
│   ├── Storage/
│   │   └── PersistenceManager.swift # Local high score & preferences storage
│   └── Views/
│       ├── GameView.swift         # Root coordinator & game layout
│       ├── ScoreHeaderView.swift  # Score, Best score & combo flame badge
│       ├── BoardView.swift        # 8x8 Grid, tile animations & praise text
│       ├── TrayView.swift         # 3-piece bottom tray container
│       ├── DraggablePieceView.swift # Drag gesture & touch offset handler
│       ├── GameOverOverlayView.swift # Instant retry game over sheet
│       └── ThemeSelectionSheet.swift # Visual theme switcher modal
└── Tests/
    └── EngineTests.swift          # Unit tests covering bitboard & game rules
```

---

## Included Themes (All Unlocked)

1. **Classic Jewel**: Vibrant electric colors (Cyan, Orange, Emerald, Pink, Gold, Purple, Crimson) on deep navy.
2. **Warm Timber**: Cozy organic wood grain palette with amber, walnut, and pine tones.
3. **Cyber Neon**: Pure OLED black background with radiant electric neon phosphor tiles.
4. **Zen Pastel**: Calming matte tones (Sage, Lavender, Peach, Powder Blue) for low visual strain.
5. **Monochrome Sleek**: High-contrast modern grayscale with platinum and silver tiles.

---

## How to Build and Run on macOS

1. Transfer or clone the repository to your Mac:
   ```bash
   git clone <repo-url>
   cd BlockBlast
   ```
2. Open the Xcode project:
   ```bash
   open BlockBlast.xcodeproj
   ```
3. Select your target simulator (e.g., **iPhone 15 Pro** or **iPhone 16 Pro**) or a connected physical iOS device.
4. Press `Cmd + R` to build and run.

---

## Running Automated Tests

Within Xcode:
- Press `Cmd + U` to execute the unit test suite in `Tests/EngineTests.swift`.

Via Command Line (macOS):
```bash
xcodebuild test -project BlockBlast.xcodeproj -scheme BlockBlast -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```
