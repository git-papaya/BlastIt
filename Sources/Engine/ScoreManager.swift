import Foundation

public enum ClearPraise: String, Equatable {
    case good = "Good!"
    case cool = "Cool!"
    case great = "Great!"
    case amazing = "Amazing!"
    case unbelievable = "Unbelievable!"
}

public struct ScoreBreakdown: Equatable {
    public let placementPoints: Int
    public let lineClearPoints: Int
    public let comboBonusPoints: Int
    public let totalAddedPoints: Int
    public let currentCombo: Int
    public let praise: ClearPraise?
}

public struct ScoreManager {
    public private(set) var currentScore: Int = 0
    public private(set) var highScore: Int = 0
    public private(set) var comboStreak: Int = 0
    public private(set) var maxComboAchieved: Int = 0
    public private(set) var totalLinesCleared: Int = 0

    public init(initialHighScore: Int = 0) {
        self.highScore = initialHighScore
    }

    public mutating func reset() {
        currentScore = 0
        comboStreak = 0
    }

    /// Evaluates placement and returns the score breakdown
    public mutating func processPlacement(piece: Piece, clearResult: ClearResult) -> ScoreBreakdown {
        let placementPoints = piece.cellCount
        var lineClearPoints = 0
        var comboBonusPoints = 0
        var praise: ClearPraise? = nil

        let lines = clearResult.linesClearedCount

        if lines > 0 {
            totalLinesCleared += lines
            comboStreak += 1
            if comboStreak > maxComboAchieved {
                maxComboAchieved = comboStreak
            }

            // Multi-line score: 10 per line + quadratic bonus for multiple lines
            lineClearPoints = lines * 10 + (lines > 1 ? lines * lines * 10 : 0)

            // Combo bonus
            comboBonusPoints = comboStreak * 25

            // Praise assignment
            if comboStreak >= 7 || lines >= 4 {
                praise = .unbelievable
            } else if comboStreak >= 5 || lines == 3 {
                praise = .amazing
            } else if comboStreak >= 3 || lines == 2 {
                praise = .great
            } else if comboStreak >= 2 {
                praise = .cool
            } else {
                praise = .good
            }
        } else {
            // Placement did not clear any lines, combo is broken
            comboStreak = 0
        }

        let totalAdded = placementPoints + lineClearPoints + comboBonusPoints
        currentScore += totalAdded

        if currentScore > highScore {
            highScore = currentScore
        }

        return ScoreBreakdown(
            placementPoints: placementPoints,
            lineClearPoints: lineClearPoints,
            comboBonusPoints: comboBonusPoints,
            totalAddedPoints: totalAdded,
            currentCombo: comboStreak,
            praise: praise
        )
    }
}
