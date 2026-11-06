import UIKit

public final class HapticManager {
    public static let shared = HapticManager()

    public var isHapticsEnabled: Bool = true

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepare()
    }

    public func prepare() {
        guard isHapticsEnabled else { return }
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        rigidImpact.prepare()
        notification.prepare()
    }

    public func pieceHover() {
        guard isHapticsEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.5)
    }

    public func piecePlaced() {
        guard isHapticsEnabled else { return }
        mediumImpact.impactOccurred(intensity: 0.8)
    }

    public func lineCleared(count: Int) {
        guard isHapticsEnabled else { return }
        if count >= 3 {
            heavyImpact.impactOccurred(intensity: 1.0)
        } else if count == 2 {
            rigidImpact.impactOccurred(intensity: 0.9)
        } else {
            mediumImpact.impactOccurred(intensity: 0.7)
        }
    }

    public func comboAchieved(streak: Int) {
        guard isHapticsEnabled else { return }
        if streak >= 3 {
            notification.notificationOccurred(.success)
        } else {
            rigidImpact.impactOccurred(intensity: min(1.0, 0.6 + Double(streak) * 0.1))
        }
    }

    public func gameOver() {
        guard isHapticsEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    public func buttonTap() {
        guard isHapticsEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.6)
    }
}
