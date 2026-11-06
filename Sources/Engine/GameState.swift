import SwiftUI
import Combine

public final class GameState: ObservableObject {
    @Published public var board: Board = Board()
    @Published public var trayPieces: [Piece?] = [nil, nil, nil]
    @Published public var score: Int = 0
    @Published public var highScore: Int = 0
    @Published public var comboCount: Int = 0
    @Published public var isGameOver: Bool = false
    @Published public var latestPraise: ClearPraise? = nil
    @Published public var praiseId: UUID = UUID()
    @Published public var activeTheme: GameTheme
    @Published public var ghostPlacement: (originRow: Int, originCol: Int, piece: Piece)? = nil
    @Published public var animatedClearingCells: Set<Coordinate> = []

    private var pieceGenerator = PieceGenerator()
    private var scoreManager: ScoreManager
    private let persistence = PersistenceManager.shared
    private let sound = SoundManager.shared
    private let haptics = HapticManager.shared

    public init() {
        let savedThemeId = persistence.selectedThemeId
        self.activeTheme = ThemeRegistry.theme(withId: savedThemeId)
        self.highScore = persistence.highScore
        self.scoreManager = ScoreManager(initialHighScore: persistence.highScore)
        self.sound.isSoundEnabled = persistence.isSoundEnabled
        self.haptics.isHapticsEnabled = persistence.isHapticsEnabled

        startNewGame()
    }

    public func startNewGame() {
        board.reset()
        scoreManager.reset()
        score = 0
        highScore = persistence.highScore
        comboCount = 0
        isGameOver = false
        latestPraise = nil
        ghostPlacement = nil
        animatedClearingCells = []

        dealNewHand()
    }

    public func dealNewHand() {
        let newBatch = pieceGenerator.generateBatch(for: board)
        trayPieces = newBatch.map { Optional($0) }
        checkGameOverCondition()
    }

    public func setGhostPlacement(originRow: Int?, originCol: Int?, piece: Piece?) {
        guard let r = originRow, let c = originCol, let p = piece else {
            ghostPlacement = nil
            return
        }

        if board.canPlace(piece: p, atOriginRow: r, originCol: c) {
            ghostPlacement = (r, c, p)
        } else {
            ghostPlacement = nil
        }
    }

    public func placePiece(index: Int, atOriginRow originRow: Int, originCol: Int) -> Bool {
        guard index >= 0 && index < trayPieces.count, let piece = trayPieces[index] else {
            return false
        }

        guard board.canPlace(piece: piece, atOriginRow: originRow, originCol: originCol) else {
            ghostPlacement = nil
            return false
        }

        ghostPlacement = nil

        // Execute placement on board
        guard let clearResult = board.place(piece: piece, atOriginRow: originRow, originCol: originCol) else {
            return false
        }

        // Remove piece from tray
        trayPieces[index] = nil

        // Process score and combo
        let breakdown = scoreManager.processPlacement(piece: piece, clearResult: clearResult)
        score = scoreManager.currentScore
        highScore = scoreManager.highScore
        comboCount = breakdown.currentCombo

        // Audio & Haptics Feedback
        if clearResult.hasClears {
            animatedClearingCells = clearResult.clearedCoordinates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.animatedClearingCells = []
            }

            if breakdown.currentCombo > 1 {
                sound.playCombo(streak: breakdown.currentCombo)
                haptics.comboAchieved(streak: breakdown.currentCombo)
            } else {
                sound.playClear()
                haptics.lineCleared(count: clearResult.linesClearedCount)
            }

            if let praise = breakdown.praise {
                latestPraise = praise
                praiseId = UUID()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                    if self?.latestPraise == praise {
                        self?.latestPraise = nil
                    }
                }
            }
        } else {
            sound.playPlace()
            haptics.piecePlaced()
        }

        // Check if hand is exhausted
        let allUsed = trayPieces.allSatisfy { $0 == nil }
        if allUsed {
            dealNewHand()
        } else {
            checkGameOverCondition()
        }

        return true
    }

    public func checkGameOverCondition() {
        let remainingPieces = trayPieces.compactMap { $0 }
        guard !remainingPieces.isEmpty else { return }

        let canAnyFit = remainingPieces.contains { piece in
            board.canPlaceAnywhere(piece: piece)
        }

        if !canAnyFit {
            isGameOver = true
            sound.playGameOver()
            haptics.gameOver()
            persistence.recordGameCompletion(
                score: score,
                maxComboInGame: scoreManager.maxComboAchieved,
                linesCleared: scoreManager.totalLinesCleared
            )
            highScore = persistence.highScore
        }
    }

    public func setTheme(_ theme: GameTheme) {
        activeTheme = theme
        persistence.selectedThemeId = theme.id
        haptics.buttonTap()
    }

    public func toggleSound() {
        sound.isSoundEnabled.toggle()
        persistence.isSoundEnabled = sound.isSoundEnabled
        haptics.buttonTap()
    }

    public func toggleHaptics() {
        haptics.isHapticsEnabled.toggle()
        persistence.isHapticsEnabled = haptics.isHapticsEnabled
        haptics.buttonTap()
    }
}
