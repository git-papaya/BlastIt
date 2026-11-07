import SwiftUI
import Combine

public struct ActiveDragState: Equatable {
    public let pieceIndex: Int
    public let piece: Piece
    public var touchLocation: CGPoint
    public var visualCenter: CGPoint
    public var hoverCell: (row: Int, col: Int)?

    public init(
        pieceIndex: Int,
        piece: Piece,
        touchLocation: CGPoint,
        visualCenter: CGPoint = .zero,
        hoverCell: (row: Int, col: Int)? = nil
    ) {
        self.pieceIndex = pieceIndex
        self.piece = piece
        self.touchLocation = touchLocation
        self.visualCenter = visualCenter
        self.hoverCell = hoverCell
    }

    public static func == (lhs: ActiveDragState, rhs: ActiveDragState) -> Bool {
        lhs.pieceIndex == rhs.pieceIndex &&
        lhs.piece.id == rhs.piece.id &&
        lhs.touchLocation == rhs.touchLocation &&
        lhs.visualCenter == rhs.visualCenter &&
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
    @Published public var boardGridOrigin: CGPoint = .zero
    @Published public var boardCellSize: CGFloat = 38.0
    @Published public var boardGridFrame: CGRect = .zero

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

        // Initialize realistic geometry based on screen dimensions
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        let boardSide = min(screenW - 32.0, 380.0)
        let padding: CGFloat = 8.0
        let gridSide = boardSide - (padding * 2.0)
        let cSize = (gridSide - 28.0) / 8.0
        let originX = (screenW - gridSide) / 2.0
        // Board is centered in vertical space between header (~160pt) and tray (~130pt)
        let availableH = screenH - 160.0 - 130.0
        let boardTop = 160.0 + max(0, (availableH - boardSide) / 2.0)
        let originY = boardTop + padding

        self.boardGridOrigin = CGPoint(x: originX, y: originY)
        self.boardCellSize = max(20.0, cSize)
        self.boardGridFrame = CGRect(x: originX, y: originY, width: gridSide, height: gridSide)

        startNewGame()
    }

    public func updateGridGeometry(frame: CGRect) {
        guard frame.width > 0 && frame.height > 0 else { return }
        self.boardGridFrame = frame
        self.boardGridOrigin = frame.origin
        let calculatedCell = (frame.width - CGFloat(Board.size - 1) * 4.0) / CGFloat(Board.size)
        if calculatedCell > 15.0 {
            self.boardCellSize = calculatedCell
        }
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
        let baseLift: CGFloat = 48.0
        let fingerGridY = location.y - boardGridOrigin.y
        let lift = BoardLayout.adaptiveLiftOffset(fingerGridY: fingerGridY, baseOffset: baseLift)
        let visualCenter = CGPoint(x: location.x, y: location.y - lift)

        activeDrag = ActiveDragState(
            pieceIndex: index,
            piece: piece,
            touchLocation: location,
            visualCenter: visualCenter
        )
        haptics.pieceHover()
        updateDrag(location: location)
    }

    public func updateDrag(location: CGPoint) {
        guard var drag = activeDrag else { return }
        drag.touchLocation = location

        let piece = drag.piece
        let cellSize = boardCellSize > 0 ? boardCellSize : 38.0
        let cellSpacing: CGFloat = 4.0
        let baseLift: CGFloat = 48.0

        let fingerGridY = location.y - boardGridOrigin.y
        let lift = BoardLayout.adaptiveLiftOffset(fingerGridY: fingerGridY, baseOffset: baseLift)
        let visualCenter = CGPoint(x: location.x, y: location.y - lift)
        drag.visualCenter = visualCenter

        // Grid-relative visual center
        let gridRelativeCenter = CGPoint(
            x: visualCenter.x - boardGridOrigin.x,
            y: visualCenter.y - boardGridOrigin.y
        )

        // Find candidate placement with minimum distance to visualCenter
        if let placement = BoardLayout.findOptimalPlacement(
            for: piece,
            nearPoint: gridRelativeCenter,
            cellSize: cellSize,
            cellSpacing: cellSpacing,
            gridSize: Board.size,
            maxDistance: 260.0,
            canPlace: { p, r, c in
                self.board.canPlace(piece: p, atOriginRow: r, originCol: c)
            }
        ) {
            if drag.hoverCell?.row != placement.row || drag.hoverCell?.col != placement.col {
                drag.hoverCell = placement
                haptics.pieceHover()
            }
            ghostPlacement = (placement.row, placement.col, piece)
        } else {
            drag.hoverCell = nil
            ghostPlacement = nil
        }

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
