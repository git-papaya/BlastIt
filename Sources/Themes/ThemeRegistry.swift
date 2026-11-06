import Foundation

public struct ThemeRegistry {
    public static let classic = GameTheme(
        id: "classic",
        name: "Classic Jewel",
        subtitle: "Vibrant jewel blocks and crisp energetic contrasts",
        iconName: "sparkles",
        backgroundTop: ThemeColor(hex: 0x0F172A),      // Slate 900
        backgroundBottom: ThemeColor(hex: 0x020617),   // Slate 950
        boardBackground: ThemeColor(hex: 0x1E293B, opacity: 0.9), // Slate 800
        emptyCell: ThemeColor(hex: 0x334155, opacity: 0.4),       // Slate 700
        gridLine: ThemeColor(hex: 0x475569, opacity: 0.2),
        ghostCell: ThemeColor(hex: 0x38BDF8, opacity: 0.35),      // Sky 400
        accent: ThemeColor(hex: 0x38BDF8),
        textPrimary: ThemeColor(hex: 0xF8FAFC),
        textSecondary: ThemeColor(hex: 0x94A3B8),
        cardBackground: ThemeColor(hex: 0x1E293B, opacity: 0.8),
        tilePalette: [
            ThemeColor(hex: 0x0EA5E9), // Cyan / Blue
            ThemeColor(hex: 0xF97316), // Orange
            ThemeColor(hex: 0x10B981), // Emerald
            ThemeColor(hex: 0xEC4899), // Pink
            ThemeColor(hex: 0xEAB308), // Amber / Gold
            ThemeColor(hex: 0x8B5CF6), // Purple
            ThemeColor(hex: 0xEF4444)  // Crimson
        ]
    )

    public static let wood = GameTheme(
        id: "wood",
        name: "Warm Timber",
        subtitle: "Organic wood grain aesthetics and cozy acoustic tones",
        iconName: "leaf.fill",
        backgroundTop: ThemeColor(hex: 0x271912),
        backgroundBottom: ThemeColor(hex: 0x180D07),
        boardBackground: ThemeColor(hex: 0x3B2317, opacity: 0.95),
        emptyCell: ThemeColor(hex: 0x4E3123, opacity: 0.5),
        gridLine: ThemeColor(hex: 0x5C3B2A, opacity: 0.3),
        ghostCell: ThemeColor(hex: 0xD97706, opacity: 0.4),
        accent: ThemeColor(hex: 0xF59E0B),
        textPrimary: ThemeColor(hex: 0xFEF3C7),
        textSecondary: ThemeColor(hex: 0xD97706),
        cardBackground: ThemeColor(hex: 0x3B2317, opacity: 0.85),
        tilePalette: [
            ThemeColor(hex: 0xD97706), // Amber Teak
            ThemeColor(hex: 0xB45309), // Warm Walnut
            ThemeColor(hex: 0x92400E), // Deep Mahogany
            ThemeColor(hex: 0xF59E0B), // Golden Pine
            ThemeColor(hex: 0x78350F), // Dark Oak
            ThemeColor(hex: 0xCD853F), // Peru Birch
            ThemeColor(hex: 0xA0522D)  // Sienna
        ]
    )

    public static let neon = GameTheme(
        id: "neon",
        name: "Cyber Neon",
        subtitle: "Futuristic dark mode with radiant phosphors",
        iconName: "bolt.fill",
        backgroundTop: ThemeColor(hex: 0x05050A),
        backgroundBottom: ThemeColor(hex: 0x000000),
        boardBackground: ThemeColor(hex: 0x0A0A14, opacity: 0.95),
        emptyCell: ThemeColor(hex: 0x1A1A2E, opacity: 0.6),
        gridLine: ThemeColor(hex: 0x2A2A4A, opacity: 0.4),
        ghostCell: ThemeColor(hex: 0x00FFF0, opacity: 0.3),
        accent: ThemeColor(hex: 0x00FFF0),
        textPrimary: ThemeColor(hex: 0xFFFFFF),
        textSecondary: ThemeColor(hex: 0x00FFF0),
        cardBackground: ThemeColor(hex: 0x0F0F1E, opacity: 0.9),
        tilePalette: [
            ThemeColor(hex: 0x00FFF0), // Electric Cyan
            ThemeColor(hex: 0xFF007F), // Neon Pink
            ThemeColor(hex: 0x39FF14), // Radioactive Lime
            ThemeColor(hex: 0xFFE600), // Strobe Yellow
            ThemeColor(hex: 0xBF00FF), // Cyber Violet
            ThemeColor(hex: 0xFF3131), // Laser Red
            ThemeColor(hex: 0x00E5FF)  // Aqua Flash
        ]
    )

    public static let pastel = GameTheme(
        id: "pastel",
        name: "Zen Pastel",
        subtitle: "Calming matte tones for low-strain relaxing sessions",
        iconName: "heart.fill",
        backgroundTop: ThemeColor(hex: 0xF3F4F6),
        backgroundBottom: ThemeColor(hex: 0xE5E7EB),
        boardBackground: ThemeColor(hex: 0xFFFFFF, opacity: 0.95),
        emptyCell: ThemeColor(hex: 0xE5E7EB, opacity: 0.8),
        gridLine: ThemeColor(hex: 0xD1D5DB, opacity: 0.5),
        ghostCell: ThemeColor(hex: 0xA78BFA, opacity: 0.35),
        accent: ThemeColor(hex: 0x8B5CF6),
        textPrimary: ThemeColor(hex: 0x1F2937),
        textSecondary: ThemeColor(hex: 0x6B7280),
        cardBackground: ThemeColor(hex: 0xFFFFFF, opacity: 0.9),
        tilePalette: [
            ThemeColor(hex: 0x93C5FD), // Pastel Blue
            ThemeColor(hex: 0xFCA5A5), // Pastel Salmon
            ThemeColor(hex: 0x86EFAC), // Pastel Mint
            ThemeColor(hex: 0xFDE047), // Pastel Banana
            ThemeColor(hex: 0xC4B5FD), // Pastel Lavender
            ThemeColor(hex: 0xFDBA74), // Pastel Peach
            ThemeColor(hex: 0x6EE7B7)  // Pastel Aqua
        ]
    )

    public static let monochrome = GameTheme(
        id: "monochrome",
        name: "Monochrome Sleek",
        subtitle: "Minimalist grayscale precision with OLED black contrast",
        iconName: "circle.lefthalf.filled",
        backgroundTop: ThemeColor(hex: 0x121212),
        backgroundBottom: ThemeColor(hex: 0x050505),
        boardBackground: ThemeColor(hex: 0x1A1A1A, opacity: 0.95),
        emptyCell: ThemeColor(hex: 0x2A2A2A, opacity: 0.6),
        gridLine: ThemeColor(hex: 0x333333, opacity: 0.4),
        ghostCell: ThemeColor(hex: 0xFFFFFF, opacity: 0.25),
        accent: ThemeColor(hex: 0xFFFFFF),
        textPrimary: ThemeColor(hex: 0xFFFFFF),
        textSecondary: ThemeColor(hex: 0x888888),
        cardBackground: ThemeColor(hex: 0x1E1E1E, opacity: 0.9),
        tilePalette: [
            ThemeColor(hex: 0xF5F5F5), // White
            ThemeColor(hex: 0xD4D4D4), // Bright Silver
            ThemeColor(hex: 0xA3A3A3), // Medium Silver
            ThemeColor(hex: 0x737373), // Neutral Gray
            ThemeColor(hex: 0xE5E5E5), // Platinum
            ThemeColor(hex: 0x909090), // Charcoal Light
            ThemeColor(hex: 0xCCCCCC)  // Soft Gray
        ]
    )

    public static let allThemes: [GameTheme] = [
        classic,
        wood,
        neon,
        pastel,
        monochrome
    ]

    public static func theme(withId id: String) -> GameTheme {
        allThemes.first { $0.id == id } ?? classic
    }
}
