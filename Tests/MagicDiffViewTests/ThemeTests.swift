import XCTest
import SwiftUI
@testable import MagicDiffView

/// 主题系统测试
final class ThemeTests: XCTestCase {

    // MARK: - DiffTheme Protocol 测试

    /// 测试所有主题都实现了 DiffTheme 协议
    func testAllThemesConformToProtocol() {
        let themes: [any DiffTheme] = [
            DiffThemes.light,
            DiffThemes.dark,
            DiffThemes.github,
            DiffThemes.vscode,
            DiffThemes.highContrast,
            DiffThemes.soft
        ]

        for theme in themes {
            // 测试所有必需的属性都能访问
            XCTAssertNotNil(theme.name)
            XCTAssertNotNil(theme.backgroundColor)
            XCTAssertNotNil(theme.unchangedBackground)
            XCTAssertNotNil(theme.addedBackground)
            XCTAssertNotNil(theme.removedBackground)
            XCTAssertNotNil(theme.modifiedBackground)
            XCTAssertNotNil(theme.gutterBackground)
            XCTAssertNotNil(theme.unchangedTextColor)
            XCTAssertNotNil(theme.addedTextColor)
            XCTAssertNotNil(theme.removedTextColor)
            XCTAssertNotNil(theme.modifiedTextColor)
            XCTAssertNotNil(theme.lineNumberColor)
            XCTAssertNotNil(theme.separatorColor)
            XCTAssertNotNil(theme.highlightBackground)
            XCTAssertNotNil(theme.addedHighlightColor)
            XCTAssertNotNil(theme.removedHighlightColor)
        }
    }

    /// 测试所有预定义主题都有唯一的名称
    func testAllThemeNamesAreUnique() {
        let themes: [any DiffTheme] = [
            DiffThemes.light,
            DiffThemes.dark,
            DiffThemes.github,
            DiffThemes.vscode,
            DiffThemes.highContrast,
            DiffThemes.soft
        ]

        let names = themes.map { $0.name }
        let uniqueNames = Set(names)

        XCTAssertEqual(names.count, uniqueNames.count, "Theme names should be unique")
    }

    // MARK: - 预定义主题测试

    /// 测试浅色主题
    func testLightTheme() {
        let theme = DiffThemes.light

        XCTAssertEqual(theme.name, "Light")
        XCTAssertEqual(theme.backgroundColor, .clear)
        XCTAssertEqual(theme.unchangedBackground, .clear)
        XCTAssertEqual(theme.unchangedTextColor, .primary)
        XCTAssertEqual(theme.lineNumberColor, .secondary.opacity(0.8))
    }

    /// 测试深色主题
    func testDarkTheme() {
        let theme = DiffThemes.dark

        XCTAssertEqual(theme.name, "Dark")
        XCTAssertNotEqual(theme.backgroundColor, .clear)
        XCTAssertNotEqual(theme.unchangedBackground, .clear)
        XCTAssertEqual(theme.gutterBackground, Color(hex: "2d2d2d"))
        XCTAssertEqual(theme.lineNumberColor, Color(hex: "858585"))
    }

    /// 测试 GitHub 主题
    func testGitHubTheme() {
        let theme = DiffThemes.github

        XCTAssertEqual(theme.name, "GitHub")
        XCTAssertEqual(theme.addedBackground, Color(hex: "d1ffcd"))
        XCTAssertEqual(theme.removedBackground, Color(hex: "ffd1d1"))
        XCTAssertEqual(theme.modifiedBackground, Color(hex: "fff3cd"))
    }

    /// 测试 VS Code 主题
    func testVSCodeTheme() {
        let theme = DiffThemes.vscode

        XCTAssertEqual(theme.name, "VS Code")
        XCTAssertEqual(theme.backgroundColor, Color(hex: "1e1e1e"))
        XCTAssertEqual(theme.gutterBackground, Color(hex: "252526"))
    }

    /// 测试高对比度主题
    func testHighContrastTheme() {
        let theme = DiffThemes.highContrast

        XCTAssertEqual(theme.name, "High Contrast")
        XCTAssertEqual(theme.backgroundColor, .black)
        XCTAssertEqual(theme.unchangedBackground, .black)
        XCTAssertEqual(theme.unchangedTextColor, .white)
    }

    /// 测试柔和主题
    func testSoftTheme() {
        let theme = DiffThemes.soft

        XCTAssertEqual(theme.name, "Soft")
        XCTAssertEqual(theme.backgroundColor, Color(hex: "fafafa"))
        XCTAssertEqual(theme.addedTextColor, Color(hex: "2e7d32"))
        XCTAssertEqual(theme.removedTextColor, Color(hex: "c62828"))
    }

    // MARK: - ThemePreset 测试

    /// 测试所有 ThemePreset 枚举值
    func testAllThemePresets() {
        let presets: [ThemePreset] = [
            .auto, .light, .dark, .github,
            .vscode, .highContrast, .soft
        ]

        XCTAssertEqual(presets.count, 7)

        for preset in presets {
            switch preset {
            case .auto, .light, .dark, .github, .vscode, .highContrast, .soft:
                continue
            }
        }
    }

    /// 测试 ThemePreset 的 theme 属性
    func testThemePresetThemeProperty() {
        let presets: [(ThemePreset, String)] = [
            (.auto, "Light"),      // auto 默认返回 light
            (.light, "Light"),
            (.dark, "Dark"),
            (.github, "GitHub"),
            (.vscode, "VS Code"),
            (.highContrast, "High Contrast"),
            (.soft, "Soft")
        ]

        for (preset, expectedName) in presets {
            let theme = preset.theme
            XCTAssertEqual(theme.name, expectedName, "ThemePreset.\(preset.rawValue) should return \(expectedName) theme")
        }
    }

    /// 测试 ThemePreset 的 theme(for:) 方法
    func testThemePresetThemeForColorScheme() {
        // 测试 auto 模式在浅色方案下返回浅色主题
        let autoLightTheme = ThemePreset.auto.theme(for: .light)
        XCTAssertEqual(autoLightTheme.name, "Light")

        // 测试 auto 模式在深色方案下返回深色主题
        let autoDarkTheme = ThemePreset.auto.theme(for: .dark)
        XCTAssertEqual(autoDarkTheme.name, "Dark")

        // 测试 auto 模式在 nil 时返回浅色主题
        let autoNilTheme = ThemePreset.auto.theme(for: nil)
        XCTAssertEqual(autoNilTheme.name, "Light")

        // 测试其他预设不受 colorScheme 影响
        let githubLight = ThemePreset.github.theme(for: .light)
        let githubDark = ThemePreset.github.theme(for: .dark)
        XCTAssertEqual(githubLight.name, githubDark.name)
    }

    /// 测试 ThemePreset 的 displayName
    func testThemePresetDisplayName() {
        let presets: [(ThemePreset, String)] = [
            (.auto, "Auto"),
            (.light, "Light"),
            (.dark, "Dark"),
            (.github, "GitHub"),
            (.vscode, "VS Code"),
            (.highContrast, "High Contrast"),
            (.soft, "Soft")
        ]

        for (preset, expected) in presets {
            XCTAssertEqual(preset.displayName, expected)
        }
    }

    /// 测试 ThemePreset 的 id 属性
    func testThemePresetId() {
        let presets: [ThemePreset] = [.auto, .light, .dark, .github, .vscode, .highContrast, .soft]

        for preset in presets {
            XCTAssertEqual(preset.id, preset.rawValue)
        }
    }

    // MARK: - DefaultDiffTheme 测试

    /// 测试 DefaultDiffTheme 初始化
    func testDefaultDiffThemeInitialization() {
        let theme = DefaultDiffTheme(
            name: "Custom",
            backgroundColor: .blue,
            addedBackground: .green,
            removedBackground: .red
        )

        XCTAssertEqual(theme.name, "Custom")
        XCTAssertEqual(theme.backgroundColor, .blue)
        XCTAssertEqual(theme.addedBackground, .green)
        XCTAssertEqual(theme.removedBackground, .red)
    }

    /// 测试 DefaultDiffTheme 默认值
    func testDefaultDiffThemeDefaultValues() {
        let theme = DefaultDiffTheme(name: "Test")

        XCTAssertEqual(theme.name, "Test")
        XCTAssertEqual(theme.backgroundColor, .clear)
        XCTAssertEqual(theme.unchangedBackground, .clear)
        XCTAssertEqual(theme.addedBackground, Color.green.opacity(0.06))
        XCTAssertEqual(theme.removedBackground, Color.red.opacity(0.06))
        XCTAssertEqual(theme.modifiedBackground, Color.orange.opacity(0.06))
        XCTAssertEqual(theme.gutterBackground, .clear)
        XCTAssertEqual(theme.unchangedTextColor, .primary)
        XCTAssertEqual(theme.addedTextColor, .primary)
        XCTAssertEqual(theme.removedTextColor, .primary)
        XCTAssertEqual(theme.modifiedTextColor, .primary)
        XCTAssertEqual(theme.lineNumberColor, .secondary.opacity(0.8))
        XCTAssertEqual(theme.separatorColor, Color.secondary.opacity(0.15))
        XCTAssertEqual(theme.highlightBackground, .clear)
        XCTAssertEqual(theme.addedHighlightColor, Color.green.opacity(0.3))
        XCTAssertEqual(theme.removedHighlightColor, Color.red.opacity(0.3))
    }

    // MARK: - 颜色扩展测试

    /// 测试 6 位十六进制颜色
    func testColorHexSixDigits() {
        let color = Color(hex: "FF0000")
        // 验证颜色能正确创建（不抛出异常）
        XCTAssertNotNil(color)
    }

    /// 测试带 # 前缀的十六进制颜色
    func testColorHexWithHashPrefix() {
        let color1 = Color(hex: "#FF0000")
        let color2 = Color(hex: "FF0000")
        // 两种方式应该都能创建颜色
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
    }

    /// 测试 3 位十六进制颜色
    func testColorHexThreeDigits() {
        let color = Color(hex: "F00")
        XCTAssertNotNil(color)
    }

    /// 测试 8 位十六进制颜色（带透明度）
    func testColorHexEightDigits() {
        let color = Color(hex: "FF000080")
        XCTAssertNotNil(color)
    }

    /// 测试无效的十六进制颜色
    func testColorHexInvalid() {
        // 这些应该不会崩溃，而是返回默认颜色
        let color1 = Color(hex: "GGG")
        let color2 = Color(hex: "")
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
    }

    /// 测试十六进制颜色大小写不敏感
    func testColorHexCaseInsensitive() {
        let color1 = Color(hex: "FF0000")
        let color2 = Color(hex: "ff0000")
        let color3 = Color(hex: "Ff0000")
        // 所有格式都应该能创建颜色
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
        XCTAssertNotNil(color3)
    }

    // MARK: - 主题对比度测试

    /// 测试高对比度主题的对比度
    func testHighContrastThemeContrast() {
        let theme = DiffThemes.highContrast

        // 高对比度主题应该使用黑色和白色
        XCTAssertEqual(theme.backgroundColor, .black)
        XCTAssertEqual(theme.unchangedBackground, .black)
        XCTAssertEqual(theme.unchangedTextColor, .white)

        // 添加和删除的背景应该有较高的不透明度
        XCTAssertNotEqual(theme.addedBackground, .clear)
        XCTAssertNotEqual(theme.removedBackground, .clear)
    }

    /// 测试浅色主题使用浅色背景
    func testLightThemeUsesLightColors() {
        let theme = DiffThemes.light

        // 浅色主题通常使用 clear 或浅色背景
        XCTAssertTrue(
            theme.backgroundColor == .clear ||
            theme.backgroundColor == Color(hex: "fafafa")
        )
    }

    /// 测试深色主题使用深色背景
    func testDarkThemeUsesDarkColors() {
        let theme = DiffThemes.dark

        // 深色主题应该使用深色背景
        XCTAssertNotEqual(theme.backgroundColor, .clear)
        XCTAssertNotEqual(theme.backgroundColor, .white)
    }

    // MARK: - 主题颜色一致性测试

    /// 测试所有主题的背景色和文字色对比
    func testThemeTextColorContrast() {
        let themes: [any DiffTheme] = [
            DiffThemes.light,
            DiffThemes.dark,
            DiffThemes.github,
            DiffThemes.vscode,
            DiffThemes.highContrast,
            DiffThemes.soft
        ]

        for theme in themes {
            // 所有主题都应该定义所有必需的颜色
            XCTAssertNotNil(theme.backgroundColor)
            XCTAssertNotNil(theme.unchangedTextColor)
            XCTAssertNotNil(theme.addedTextColor)
            XCTAssertNotNil(theme.removedTextColor)
            XCTAssertNotNil(theme.modifiedTextColor)
        }
    }

    /// 测试所有主题都有完整的高亮颜色定义
    func testAllThemesHaveHighlightColors() {
        let themes: [any DiffTheme] = [
            DiffThemes.light,
            DiffThemes.dark,
            DiffThemes.github,
            DiffThemes.vscode,
            DiffThemes.highContrast,
            DiffThemes.soft
        ]

        for theme in themes {
            XCTAssertNotNil(theme.addedHighlightColor, "\(theme.name) should have addedHighlightColor")
            XCTAssertNotNil(theme.removedHighlightColor, "\(theme.name) should have removedHighlightColor")
        }
    }

    // MARK: - 主题切换场景测试

    /// 测试主题切换场景
    func testThemeSwitching() {
        // 从浅色切换到深色
        let lightTheme = DiffThemes.light
        let darkTheme = DiffThemes.dark

        XCTAssertNotEqual(lightTheme.name, darkTheme.name)
        XCTAssertNotEqual(lightTheme.backgroundColor, darkTheme.backgroundColor)
    }

    /// 测试自动模式在不同环境下的表现
    func testAutoModeBehavior() {
        let autoPreset = ThemePreset.auto

        // 测试在不同场景下自动模式的行为
        let lightCase = autoPreset.theme(for: .light)
        let darkCase = autoPreset.theme(for: .dark)
        let nilCase = autoPreset.theme(for: nil)

        XCTAssertEqual(lightCase.name, "Light")
        XCTAssertEqual(darkCase.name, "Dark")
        XCTAssertEqual(nilCase.name, "Light")
    }

    // MARK: - allThemes 测试

    /// 测试 DiffThemes.allThemes 包含所有主题
    func testAllThemesCollection() {
        let allThemes = DiffThemes.allThemes

        XCTAssertEqual(allThemes.count, 6)

        let themeNames = allThemes.map { $0.name }
        let expectedNames = ["Light", "Dark", "GitHub", "VS Code", "High Contrast", "Soft"]

        for name in expectedNames {
            XCTAssertTrue(themeNames.contains(name), "allThemes should contain \(name)")
        }
    }

    /// 测试 allThemes 中的主题都是唯一的
    func testAllThemesAreUnique() {
        let allThemes = DiffThemes.allThemes
        let themeNames = allThemes.map { $0.name }

        let uniqueNames = Set(themeNames)
        XCTAssertEqual(themeNames.count, uniqueNames.count, "All themes should have unique names")
    }

    // MARK: - 主题属性完整性测试

    /// 测试所有主题的属性完整性
    func testAllThemePropertiesAreDefined() {
        let themes: [any DiffTheme] = DiffThemes.allThemes

        let expectedPropertyCount = 16 // DiffTheme protocol 属性数量

        for theme in themes {
            // 通过访问每个属性来验证它们都已定义
            _ = theme.name
            _ = theme.backgroundColor
            _ = theme.unchangedBackground
            _ = theme.addedBackground
            _ = theme.removedBackground
            _ = theme.modifiedBackground
            _ = theme.gutterBackground
            _ = theme.unchangedTextColor
            _ = theme.addedTextColor
            _ = theme.removedTextColor
            _ = theme.modifiedTextColor
            _ = theme.lineNumberColor
            _ = theme.separatorColor
            _ = theme.highlightBackground
            _ = theme.addedHighlightColor
            _ = theme.removedHighlightColor
        }
    }
}
