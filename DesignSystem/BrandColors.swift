import SwiftUI

public enum LpColors {
    // Cores Principais da Marca
    public static let gold = Color(hex: 0xF2B01E)
    public static let goldLight = Color(hex: 0xFFD25A)
    public static let goldSoft = Color(hex: 0xFFE08A)
    public static let wine = Color(hex: 0xB3152B)
    public static let favorite = Color(hex: 0xE0314B)

    // Superfícies Escuras
    public static let darkBackground = Color(hex: 0x0D0907)
    public static let darkSurface1 = Color(hex: 0x1A1210)
    public static let darkSurface2 = Color(hex: 0x261A16)
    public static let darkSurface3 = Color(hex: 0x33231D)
    public static let darkSurfaceLowest = Color(hex: 0x120C09)
    public static let darkDivider = Color(hex: 0x3A2A22)

    // Textos
    public static let textPrimary = Color(hex: 0xF5F5F7)
    public static let textSecondary = Color(hex: 0xB8A99A)
    public static let textTertiary = Color(hex: 0x7A6E64)

    // Gradientes Oficiais
    public static let gradientPrimary = LinearGradient(
        colors: [goldLight, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let gradientBrand = LinearGradient(
        colors: [gold, wine],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let gradientPlayerFallback = LinearGradient(
        colors: [wine.opacity(0.85), darkSurface2, darkBackground],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let gradientMiniPlayer = LinearGradient(
        colors: [darkSurface2, darkSurface1],
        startPoint: .top,
        endPoint: .bottom
    )
}

// Extensão auxiliar para criação de Color a partir de Hexadecimal
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
