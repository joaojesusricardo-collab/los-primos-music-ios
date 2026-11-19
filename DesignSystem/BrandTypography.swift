import SwiftUI

public enum LpTypography {
    public static func titleHero(_ size: CGFloat = 28) -> Font {
        .custom("PlusJakartaSans-ExtraBold", size: size)
    }

    public static func titleSection(_ size: CGFloat = 20) -> Font {
        .custom("PlusJakartaSans-SemiBold", size: size)
    }

    public static func titleMedium(_ size: CGFloat = 17) -> Font {
        .custom("PlusJakartaSans-SemiBold", size: size)
    }

    public static func bodyMedium(_ size: CGFloat = 15) -> Font {
        .custom("Inter-Medium", size: size)
    }

    public static func bodyRegular(_ size: CGFloat = 14) -> Font {
        .custom("Inter-Regular", size: size)
    }

    public static func caption(_ size: CGFloat = 12) -> Font {
        .custom("Inter-Regular", size: size)
    }
}

public enum LpDimensions {
    public static let space4: CGFloat = 4
    public static let space8: CGFloat = 8
    public static let space12: CGFloat = 12
    public static let space16: CGFloat = 16
    public static let space20: CGFloat = 20
    public static let space24: CGFloat = 24
    public static let space32: CGFloat = 32

    public static let minTouchTarget: CGFloat = 48
    public static let cardRadius: CGFloat = 16
    public static let coverRadius: CGFloat = 20
    public static let heroRadius: CGFloat = 28
    public static let sheetRadius: CGFloat = 28
    public static let chipRadius: CGFloat = 20
    public static let buttonRadius: CGFloat = 26
}
