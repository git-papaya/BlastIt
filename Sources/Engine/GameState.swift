import SwiftUI
import Combine

public struct ActiveDragState: Equatable {
    public let pieceIndex: Int
    public let piece: Piece
    public var touchLocation: CGPoint
    public var hoverCell: (row: Int, col: Int)?

    public init(pieceIndex: Int, piece: Piece, touchLocation: CGPoint, hoverCell: (row: Int, col: Int)? = nil) {
        self.pieceIndex = pieceIndex
        self.piece = piece
        self.touchLocation = touchLocation
        self.hoverCell = hoverCell
    }

    public static func == (lhs: ActiveDragState, rhs: ActiveDragState) -> Bool {
        lhs.pieceIndex == rhs.pieceIndex &&
        lhs.piece.id == rhs.piece.id &&
        lhs.touchLocation == rhs.touchLocation &&
        lhs.hoverCell?.row == rhs.hoverCell?.row &&
        lhs.hoverCell?.col == rhs.hoverCell?.col
    }
}

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
    @Published public var activeDrag: ActiveDragState? = nil

    // Geometry measured from BoardView in window (.global) coordinates
    @Published public var boardGridOrigin: CGPoint = CGPoint(x: 24.0, y: 220.0)
    @Published public var boardCellSize: CGFloat = 38.0

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

        // Initialize reasonable geometry defaults based on screen size
        let screenW = UIScreen.main.bounds.width
        let boardSize = min(screenW - 32.0, 380.0)
        let innerSize = boardSize - 16.0
        let cSize = (innerSize - 28.0) / 8.0
        let originX = (screenW - boardSize) / 2.0 + 8.0
        self.boardGridOrigin = CGPoint(x: originX, y: 220.0)
        self.boardCellSize = cSize

        startNewGame()
    }

    public func setBoardGeometry(origin: CGPoint, cellSize: CGFloat) {
        guard origin.x > 0 && origin.y > 0 && cellSize > 0 else { return }
        self.boardGridOrigin = origin
        self.boardCellSize = cellSize
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
        activeDrag = nil

        dealNewHand()
    }

    public func dealNewHand() {
        let newBatch = pieceGenerator.generateBatch(for: board)
        trayPieces = newBatch.map { Optional($0) }
        checkGameOverCondition()
    }

    // MARK: - Drag & Drop Coordinator

    public func startDrag(index: Int, piece: Piece, location: CGPoint) {
        activeDrag = ActiveDragState(pieceIndex: index, piece: piece, touchLocation: location)
        haptics.pieceHover()
    }

    public func updateDrag(location: CGPoint) {
        guard var drag = activeDrag else { return }
        drag.touchLocation = location

        let piece = drag.piece
        let cellSize = boardCellSize > 0 ? boardCellSize : 38.0
        let cellStep = cellSize + 4.0
        let fingerOffset: CGFloat = 60.0

        // Floating piece center in screen coordinates
        let pieceCenterX = location.x
        let pieceCenterY = location.y - fingerOffset

        // Center of top-left cell (0, 0) of the piece
        let cell0CenterX = pieceCenterX - (CGFloat(piece.width - 1) * cellStep / 2.0)
        let cell0CenterY = pieceCenterY - (CGFloat(piece.height - 1) * cellStep / 2.0)

        // Board cell (0, 0) center in screen coordinates
        let board0CenterX = boardGridOrigin.x + (cellSize / 2.0)
        let board0CenterY = boardGridOrigin.y + (cellSize / 2.0)

        if cellStep > 0 {
            let targetCol = Int(round((cell0CenterX - board0CenterX) / cellStep))
            let targetRow = Int(round((cell0CenterY - board0CenterY) / cellStep))

            if targetRow >= 0 && targetRow <= (Board.size - piece.height) &&
               targetCol >= 0 && targetCol <= (Board.size - piece.width) {
                if board.canPlace(piece: piece, atOriginRow: targetRow, originCol: targetCol) {
                    if drag.hoverCell?.row != targetRow || drag.hoverCell?.col != targetCol {
                        drag.hoverCell = (targetRow, targetCol)
                        haptics.pieceHover()
                    }
                    ghostPlacement = (targetRow, targetCol, piece)
                    activeDrag = drag
                    return
                }
            }
        }

        drag.hoverCell = nil
        ghostPlacement = nil
        activeDrag = drag
    }

    public func endDrag() {
        guard let drag = activeDrag else { return }
        if let target = drag.hoverCell {
            _ = placePiece(index: drag.pieceIndex, atOriginRow: target.row, originCol: target.col)
        }
        activeDrag = nil
        ghostPlacement = nil
    }

    public func cancelDrag() {
        activeDrag = nil
        ghostPlacement = nil
    }

    // MARK: - Game Actions

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
