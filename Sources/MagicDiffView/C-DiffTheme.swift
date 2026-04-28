import SwiftUI

/// 差异视图主题协议
public protocol DiffTheme {
    /// 主题名称
    var name: String { get }

    /// 背景颜色
    var backgroundColor: Color { get }

    /// 未改变行的背景颜色
    var unchangedBackground: Color { get }

    /// 添加行的背景颜色
    var addedBackground: Color { get }

    /// 删除行的背景颜色
    var removedBackground: Color { get }

    /// 修改行的背景颜色
    var modifiedBackground: Color { get }

    /// 行号区域背景颜色
    var gutterBackground: Color { get }

    /// Hunk Header 背景颜色（GitHub Desktop 蓝色风格）
    var hunkHeaderBackground: Color { get }

    /// 未改变行的文字颜色
    var unchangedTextColor: Color { get }

    /// 添加行的文字颜色
    var addedTextColor: Color { get }

    /// 删除行的文字颜色
    var removedTextColor: Color { get }

    /// 修改行的文字颜色
    var modifiedTextColor: Color { get }

    /// 行号文字颜色
    var lineNumberColor: Color { get }

    /// 分割线颜色
    var separatorColor: Color { get }

    /// 高亮背景颜色
    var highlightBackground: Color { get }

    /// 添加行的高亮颜色
    var addedHighlightColor: Color { get }

    /// 删除行的高亮颜色
    var removedHighlightColor: Color { get }
}

/// 默认主题结构体
public struct DefaultDiffTheme: DiffTheme {
    public let name: String
    public let backgroundColor: Color
    public let unchangedBackground: Color
    public let addedBackground: Color
    public let removedBackground: Color
    public let modifiedBackground: Color
    public let gutterBackground: Color
    public let hunkHeaderBackground: Color
    public let unchangedTextColor: Color
    public let addedTextColor: Color
    public let removedTextColor: Color
    public let modifiedTextColor: Color
    public let lineNumberColor: Color
    public let separatorColor: Color
    public let highlightBackground: Color
    public let addedHighlightColor: Color
    public let removedHighlightColor: Color

    public init(
        name: String,
        backgroundColor: Color = .clear,
        unchangedBackground: Color = .clear,
        addedBackground: Color = Color.green.opacity(0.06),
        removedBackground: Color = Color.red.opacity(0.06),
        modifiedBackground: Color = Color.orange.opacity(0.06),
        gutterBackground: Color = .clear,
        hunkHeaderBackground: Color? = nil,
        unchangedTextColor: Color = .primary,
        addedTextColor: Color = .primary,
        removedTextColor: Color = .primary,
        modifiedTextColor: Color = .primary,
        lineNumberColor: Color = .secondary.opacity(0.8),
        separatorColor: Color = Color.secondary.opacity(0.15),
        highlightBackground: Color = .clear,
        addedHighlightColor: Color = Color.green.opacity(0.3),
        removedHighlightColor: Color = Color.red.opacity(0.3)
    ) {
        self.name = name
        self.backgroundColor = backgroundColor
        self.unchangedBackground = unchangedBackground
        self.addedBackground = addedBackground
        self.removedBackground = removedBackground
        self.modifiedBackground = modifiedBackground
        self.gutterBackground = gutterBackground
        self.hunkHeaderBackground = hunkHeaderBackground ?? Color.blue.opacity(0.06)
        self.unchangedTextColor = unchangedTextColor
        self.addedTextColor = addedTextColor
        self.removedTextColor = removedTextColor
        self.modifiedTextColor = modifiedTextColor
        self.lineNumberColor = lineNumberColor
        self.separatorColor = separatorColor
        self.highlightBackground = highlightBackground
        self.addedHighlightColor = addedHighlightColor
        self.removedHighlightColor = removedHighlightColor
    }
}

/// 预定义主题集合
public enum DiffThemes {
    /// 浅色主题（默认）
    public static let light = DefaultDiffTheme(
        name: "Light",
        backgroundColor: .clear,
        unchangedBackground: .clear,
        addedBackground: Color.green.opacity(0.06),
        removedBackground: Color.red.opacity(0.06),
        modifiedBackground: Color.orange.opacity(0.06),
        gutterBackground: .clear,
        hunkHeaderBackground: Color(hex: "edf2f8"),
        unchangedTextColor: .primary,
        addedTextColor: .primary,
        removedTextColor: .primary,
        modifiedTextColor: .primary,
        lineNumberColor: .secondary.opacity(0.8),
        separatorColor: Color.secondary.opacity(0.15),
        highlightBackground: .clear,
        addedHighlightColor: Color.green.opacity(0.45),
        removedHighlightColor: Color.red.opacity(0.45)
    )

    /// 深色主题
    public static let dark = DefaultDiffTheme(
        name: "Dark",
        backgroundColor: Color(hex: "1e1e1e"),
        unchangedBackground: Color(hex: "1e1e1e"),
        addedBackground: Color(hex: "1e3a1e").opacity(0.3),
        removedBackground: Color(hex: "3a1e1e").opacity(0.3),
        modifiedBackground: Color(hex: "3a2e1e").opacity(0.3),
        gutterBackground: Color(hex: "2d2d2d"),
        hunkHeaderBackground: Color(hex: "264f78").opacity(0.3),
        unchangedTextColor: Color(hex: "cccccc"),
        addedTextColor: Color(hex: "cccccc"),
        removedTextColor: Color(hex: "cccccc"),
        modifiedTextColor: Color(hex: "cccccc"),
        lineNumberColor: Color(hex: "858585"),
        separatorColor: Color(hex: "3e3e3e"),
        highlightBackground: Color(hex: "264f78").opacity(0.3),
        addedHighlightColor: Color(hex: "4a7c59"),
        removedHighlightColor: Color(hex: "7c4a4a")
    )

    /// GitHub 风格主题
    public static let github = DefaultDiffTheme(
        name: "GitHub",
        backgroundColor: .clear,
        unchangedBackground: .clear,
        addedBackground: Color(hex: "d1ffcd"),
        removedBackground: Color(hex: "ffd1d1"),
        modifiedBackground: Color(hex: "fff3cd"),
        gutterBackground: .clear,
        unchangedTextColor: .primary,
        addedTextColor: Color(hex: "24292f"),
        removedTextColor: Color(hex: "24292f"),
        modifiedTextColor: Color(hex: "24292f"),
        lineNumberColor: Color(hex: "656d76"),
        separatorColor: Color(hex: "d1d9e0"),
        highlightBackground: .clear,
        addedHighlightColor: Color(hex: "55a532").opacity(0.5),
        removedHighlightColor: Color(hex: "bd2c00").opacity(0.5)
    )

    /// VS Code 风格主题
    public static let vscode = DefaultDiffTheme(
        name: "VS Code",
        backgroundColor: Color(hex: "1e1e1e"),
        unchangedBackground: Color(hex: "1e1e1e"),
        addedBackground: Color(hex: "374e2a").opacity(0.4),
        removedBackground: Color(hex: "5c3030").opacity(0.4),
        modifiedBackground: Color(hex: "5c4e30").opacity(0.4),
        gutterBackground: Color(hex: "252526"),
        unchangedTextColor: Color(hex: "cccccc"),
        addedTextColor: Color(hex: "cccccc"),
        removedTextColor: Color(hex: "cccccc"),
        modifiedTextColor: Color(hex: "cccccc"),
        lineNumberColor: Color(hex: "858585"),
        separatorColor: Color(hex: "454545"),
        highlightBackground: Color(hex: "264f78").opacity(0.4),
        addedHighlightColor: Color(hex: "4ec9b0").opacity(0.5),
        removedHighlightColor: Color(hex: "f44747").opacity(0.5)
    )

    /// 高对比度主题
    public static let highContrast = DefaultDiffTheme(
        name: "High Contrast",
        backgroundColor: .black,
        unchangedBackground: .black,
        addedBackground: Color.green.opacity(0.8),
        removedBackground: Color.red.opacity(0.8),
        modifiedBackground: Color.yellow.opacity(0.8),
        gutterBackground: Color.gray.opacity(0.2),
        unchangedTextColor: .white,
        addedTextColor: .black,
        removedTextColor: .black,
        modifiedTextColor: .black,
        lineNumberColor: .yellow,
        separatorColor: .white.opacity(0.5),
        highlightBackground: .blue.opacity(0.5),
        addedHighlightColor: Color.green.opacity(0.9),
        removedHighlightColor: Color.red.opacity(0.9)
    )

    /// 柔和色彩主题
    public static let soft = DefaultDiffTheme(
        name: "Soft",
        backgroundColor: Color(hex: "fafafa"),
        unchangedBackground: Color(hex: "fafafa"),
        addedBackground: Color(hex: "e8f5e8"),
        removedBackground: Color(hex: "ffeaea"),
        modifiedBackground: Color(hex: "fff8e1"),
        gutterBackground: Color(hex: "f5f5f5"),
        unchangedTextColor: Color(hex: "424242"),
        addedTextColor: Color(hex: "2e7d32"),
        removedTextColor: Color(hex: "c62828"),
        modifiedTextColor: Color(hex: "ef6c00"),
        lineNumberColor: Color(hex: "9e9e9e"),
        separatorColor: Color(hex: "e0e0e0"),
        highlightBackground: Color(hex: "e3f2fd"),
        addedHighlightColor: Color(hex: "4caf50").opacity(0.4),
        removedHighlightColor: Color(hex: "f44336").opacity(0.4)
    )

    /// 所有可用主题
    public static let allThemes: [any DiffTheme] = [light, dark, github, vscode, highContrast, soft]
}

/// 主题选择枚举
public enum ThemePreset: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case light = "Light"
    case dark = "Dark"
    case github = "GitHub"
    case vscode = "VS Code"
    case highContrast = "High Contrast"
    case soft = "Soft"

    public var id: String { rawValue }

    /// 获取对应的主题（自动模式默认使用浅色主题）
    public var theme: any DiffTheme {
        switch self {
        case .auto: return DiffThemes.light
        case .light: return DiffThemes.light
        case .dark: return DiffThemes.dark
        case .github: return DiffThemes.github
        case .vscode: return DiffThemes.vscode
        case .highContrast: return DiffThemes.highContrast
        case .soft: return DiffThemes.soft
        }
    }

    /// 根据系统颜色方案获取对应的主题
    /// - Parameter colorScheme: 系统颜色方案
    /// - Returns: 对应的主题，如果是自动模式则根据颜色方案返回 light 或 dark
    public func theme(for colorScheme: ColorScheme?) -> any DiffTheme {
        switch self {
        case .auto:
            if let colorScheme = colorScheme {
                return colorScheme == .dark ? DiffThemes.dark : DiffThemes.light
            }
            return DiffThemes.light
        case .light: return DiffThemes.light
        case .dark: return DiffThemes.dark
        case .github: return DiffThemes.github
        case .vscode: return DiffThemes.vscode
        case .highContrast: return DiffThemes.highContrast
        case .soft: return DiffThemes.soft
        }
    }

    /// 显示名称
    public var displayName: String {
        rawValue
    }
}

// MARK: - Color Extension
extension Color {
    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制颜色字符串（如 "FF0000" 或 "#FF0000"）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
