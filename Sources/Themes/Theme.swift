import SwiftUI

public struct ThemeColor: Equatable, Hashable, Codable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    public init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }

    public var swiftUIColor: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

public struct GameTheme: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let iconName: String
    
    public let backgroundTop: ThemeColor
    public let backgroundBottom: ThemeColor
    public let boardBackground: ThemeColor
    public let emptyCell: ThemeColor
    public let gridLine: ThemeColor
    public let ghostCell: ThemeColor
    public let accent: ThemeColor
    public let textPrimary: ThemeColor
    public let textSecondary: ThemeColor
    public let cardBackground: ThemeColor
    public let tilePalette: [ThemeColor]

    public func tileColor(for index: Int) -> ThemeColor {
        guard !tilePalette.isEmpty else {
            return ThemeColor(hex: 0x4A90E2)
        }
        let safeIndex = abs(index) % tilePalette.count
        return tilePalette[safeIndex]
    }
}
