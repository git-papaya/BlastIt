import Foundation

public final class PersistenceManager {
    public static let shared = PersistenceManager()

    private enum Keys {
        static let highScore = "bb_high_score"
        static let gamesPlayed = "bb_games_played"
        static let maxCombo = "bb_max_combo"
        static let totalLinesCleared = "bb_total_lines_cleared"
        static let selectedThemeId = "bb_selected_theme_id"
        static let isSoundEnabled = "bb_is_sound_enabled"
        static let isHapticsEnabled = "bb_is_haptics_enabled"
    }

    private let defaults = UserDefaults.standard

    private init() {}

    public var highScore: Int {
        get { defaults.integer(forKey: Keys.highScore) }
        set { defaults.set(newValue, forKey: Keys.highScore) }
    }

    public var gamesPlayed: Int {
        get { defaults.integer(forKey: Keys.gamesPlayed) }
        set { defaults.set(newValue, forKey: Keys.gamesPlayed) }
    }

    public var maxCombo: Int {
        get { defaults.integer(forKey: Keys.maxCombo) }
        set { defaults.set(newValue, forKey: Keys.maxCombo) }
    }

    public var totalLinesCleared: Int {
        get { defaults.integer(forKey: Keys.totalLinesCleared) }
        set { defaults.set(newValue, forKey: Keys.totalLinesCleared) }
    }

    public var selectedThemeId: String {
        get { defaults.string(forKey: Keys.selectedThemeId) ?? "classic" }
        set { defaults.set(newValue, forKey: Keys.selectedThemeId) }
    }

    public var isSoundEnabled: Bool {
        get { defaults.object(forKey: Keys.isSoundEnabled) == nil ? true : defaults.bool(forKey: Keys.isSoundEnabled) }
        set { defaults.set(newValue, forKey: Keys.isSoundEnabled) }
    }

    public var isHapticsEnabled: Bool {
        get { defaults.object(forKey: Keys.isHapticsEnabled) == nil ? true : defaults.bool(forKey: Keys.isHapticsEnabled) }
        set { defaults.set(newValue, forKey: Keys.isHapticsEnabled) }
    }

    public func recordGameCompletion(score: Int, maxComboInGame: Int, linesCleared: Int) {
        gamesPlayed += 1
        if score > highScore {
            highScore = score
        }
        if maxComboInGame > maxCombo {
            maxCombo = maxComboInGame
        }
        totalLinesCleared += linesCleared
    }
}
