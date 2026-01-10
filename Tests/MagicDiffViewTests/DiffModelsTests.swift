import XCTest
@testable import MagicDiffView

/// 差异数据模型测试
final class DiffModelsTests: XCTestCase {

    // MARK: - DiffLine Tests

    /// 测试 DiffLine 创建
    func testDiffLineCreation() {
        let line = DiffLine(
            content: "test content",
            type: .added,
            oldLineNumber: nil,
            newLineNumber: 1
        )

        XCTAssertEqual(line.content, "test content")
        XCTAssertEqual(line.type, .added)
        XCTAssertNil(line.oldLineNumber)
        XCTAssertEqual(line.newLineNumber, 1)
    }

    /// 测试 DiffLine 属性访问
    func testDiffLineProperties() {
        let line1 = DiffLine(
            content: "test",
            type: .unchanged,
            oldLineNumber: 1,
            newLineNumber: 1
        )

        let line2 = DiffLine(
            content: "different",
            type: .added,
            oldLineNumber: nil,
            newLineNumber: 2
        )

        // 测试属性可以正确访问
        XCTAssertEqual(line1.content, "test")
        XCTAssertEqual(line1.type, .unchanged)
        XCTAssertEqual(line1.oldLineNumber, 1)
        XCTAssertEqual(line1.newLineNumber, 1)

        XCTAssertEqual(line2.content, "different")
        XCTAssertEqual(line2.type, .added)
        XCTAssertNil(line2.oldLineNumber)
        XCTAssertEqual(line2.newLineNumber, 2)
    }

    /// 测试所有 DiffType 枚举值
    func testAllDiffTypes() {
        let types: [DiffType] = [.unchanged, .added, .removed, .modified]

        for type in types {
            switch type {
            case .unchanged, .added, .removed, .modified:
                continue
            }
        }
    }

    // MARK: - DiffItem Tests

    /// 测试 DiffLine Item
    func testDiffLineItem() {
        let line = DiffLine(
            content: "test",
            type: .added,
            oldLineNumber: nil,
            newLineNumber: 1
        )

        let item = DiffItem.line(line)

        if case .line(let l) = item {
            XCTAssertEqual(l.content, line.content)
            XCTAssertEqual(l.type, line.type)
        } else {
            XCTFail("应该是 line item")
        }
    }

    /// 测试 CollapsibleBlock Item
    func testCollapsibleBlockItem() {
        let lines = [
            DiffLine(content: "line 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 1),
            DiffLine(content: "line 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 2)
        ]

        let block = CollapsibleBlock(
            lines: lines,
            isCollapsed: true,
            startLineNumber: 1,
            endLineNumber: 2
        )

        let item = DiffItem.collapsibleBlock(block)

        if case .collapsibleBlock(let b) = item {
            XCTAssertEqual(b.lines.count, block.lines.count)
            XCTAssertEqual(b.isCollapsed, block.isCollapsed)
        } else {
            XCTFail("应该是 collapsibleBlock item")
        }
    }

    // MARK: - CollapsibleBlock Tests

    /// 测试 CollapsibleBlock 创建
    func testCollapsibleBlockCreation() {
        let lines = [
            DiffLine(content: "line 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 1),
            DiffLine(content: "line 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 2),
            DiffLine(content: "line 3", type: .unchanged, oldLineNumber: 3, newLineNumber: 3)
        ]

        let block = CollapsibleBlock(
            lines: lines,
            isCollapsed: true,
            startLineNumber: 10,
            endLineNumber: 12
        )

        XCTAssertEqual(block.lines.count, 3)
        XCTAssertTrue(block.isCollapsed)
        XCTAssertEqual(block.startLineNumber, 10)
        XCTAssertEqual(block.endLineNumber, 12)
    }

    /// 测试 CollapsibleBlock 属性访问
    func testCollapsibleBlockProperties() {
        let lines = [
            DiffLine(content: "test", type: .unchanged, oldLineNumber: 1, newLineNumber: 1)
        ]

        let block1 = CollapsibleBlock(
            lines: lines,
            isCollapsed: true,
            startLineNumber: 1,
            endLineNumber: 1
        )

        let block2 = CollapsibleBlock(
            lines: lines,
            isCollapsed: false,
            startLineNumber: 1,
            endLineNumber: 1
        )

        // 测试两个不同的 block 可以有不同的状态
        XCTAssertTrue(block1.isCollapsed)
        XCTAssertFalse(block2.isCollapsed)
        XCTAssertEqual(block1.lines.count, block2.lines.count)
    }

    // MARK: - ViewMode Tests

    /// 测试 ViewMode 枚举
    func testViewModeCases() {
        let modes: [ViewMode] = [.diff, .sideBySide, .original, .modified]

        XCTAssertEqual(modes.count, 4)

        for mode in modes {
            switch mode {
            case .diff:
                break
            case .sideBySide:
                break
            case .original:
                break
            case .modified:
                break
            }
        }
    }

    /// 测试 ViewMode isComparisonMode 属性
    func testViewModeIsComparisonMode() {
        XCTAssertTrue(ViewMode.diff.isComparisonMode)
        XCTAssertTrue(ViewMode.sideBySide.isComparisonMode)
        XCTAssertFalse(ViewMode.original.isComparisonMode)
        XCTAssertFalse(ViewMode.modified.isComparisonMode)
    }

    // MARK: - DiffType Tests

    /// 测试 DiffType 描述
    func testDiffTypeDescriptions() {
        let types: [DiffType] = [.unchanged, .added, .removed, .modified]

        for type in types {
            let description = String(describing: type)
            XCTAssertFalse(description.isEmpty)
        }
    }

    /// 测试 DiffType 枚举值
    func testDiffTypeEnumValues() {
        let types: [DiffType] = [.unchanged, .added, .removed, .modified]
        XCTAssertEqual(types.count, 4)

        // 验证所有枚举值都可以遍历
        for type in types {
            switch type {
            case .unchanged, .added, .removed, .modified:
                continue
            }
        }
    }

    // MARK: - Theme Tests

    /// 测试所有主题预设
    func testAllThemePresets() {
        let presets: [ThemePreset] = [.auto, .light, .dark, .github, .vscode, .highContrast, .soft]

        for preset in presets {
            switch preset {
            case .auto, .light, .dark, .github, .vscode, .highContrast, .soft:
                continue
            }
        }
    }

    /// 测试主题创建
    func testThemeCreation() {
        let themes: [any DiffTheme] = [
            DiffThemes.light,
            DiffThemes.dark,
            DiffThemes.github,
            DiffThemes.vscode,
            DiffThemes.highContrast,
            DiffThemes.soft
        ]

        XCTAssertEqual(themes.count, 6)

        for theme in themes {
            XCTAssertNotNil(theme.addedBackground)
            XCTAssertNotNil(theme.removedBackground)
            XCTAssertNotNil(theme.addedHighlightColor)
            XCTAssertNotNil(theme.removedHighlightColor)
            XCTAssertNotNil(theme.gutterBackground)
            XCTAssertNotNil(theme.lineNumberColor)
        }
    }

    /// 测试 ThemePreset 主题切换
    func testThemePreset() {
        let autoPreset = ThemePreset.auto

        // 测试浅色模式
        let lightTheme = autoPreset.theme(for: .light)
        XCTAssertNotNil(lightTheme)
        XCTAssertEqual(lightTheme.name, "Light")

        // 测试深色模式
        let darkTheme = autoPreset.theme(for: .dark)
        XCTAssertNotNil(darkTheme)
        XCTAssertEqual(darkTheme.name, "Dark")

        // 两种模式应该返回不同的主题
        XCTAssertNotEqual(lightTheme.name, darkTheme.name)
    }

    // MARK: - Complex Scenarios

    /// 测试真实的代码差异场景
    func testRealWorldCodeDiff() {
        let oldCode = """
struct User {
    let name: String
    let email: String

    func validate() -> Bool {
        return !name.isEmpty
    }
}
""".components(separatedBy: .newlines)

        let newCode = """
struct User {
    let id: Int
    let name: String
    let email: String
    let age: Int?

    func validate() -> Bool {
        guard !name.isEmpty else { return false }
        guard !email.isEmpty else { return false }
        return true
    }
}
""".components(separatedBy: .newlines)

        let result = DiffAlgorithm.computeDiff(oldLines: oldCode, newLines: newCode)

        // 应该有差异
        XCTAssertFalse(result.isEmpty, "Diff result should not be empty")

        // 应该有添加的行
        let addedLines = result.filter { $0.type == .added }
        XCTAssertFalse(addedLines.isEmpty, "Should have added lines")

        // 应该有删除的行
        let removedLines = result.filter { $0.type == .removed }
        XCTAssertFalse(removedLines.isEmpty, "Should have removed lines")

        // 验证特定内容的存在
        let allContent = result.map { $0.content }.joined(separator: "\n")
        XCTAssertTrue(allContent.contains("let id"), "Should contain 'let id'")
    }

    /// 测试折叠逻辑的组织
    func testFoldingLogic() {
        // 创建足够多的未修改行来触发折叠
        var lines: [DiffLine] = []

        // 添加 5 行未修改的内容
        for i in 1...5 {
            lines.append(DiffLine(
                content: "unchanged \(i)",
                type: .unchanged,
                oldLineNumber: i,
                newLineNumber: i
            ))
        }

        // 添加一个修改的行
        lines.append(DiffLine(
            content: "modified line",
            type: .modified,
            oldLineNumber: 6,
            newLineNumber: 6
        ))

        // 再添加 5 行未修改的内容
        for i in 7...11 {
            lines.append(DiffLine(
                content: "unchanged \(i)",
                type: .unchanged,
                oldLineNumber: i,
                newLineNumber: i
            ))
        }

        let items = DiffAlgorithm.organizeDiffItems(from: lines, minUnchangedLines: 3)

        // 应该有 3 个项目：第一个折叠块 + 修改行 + 第二个折叠块
        XCTAssertEqual(items.count, 3)

        if case .collapsibleBlock(let first) = items[0] {
            XCTAssertEqual(first.lines.count, 5)
        } else {
            XCTFail("第一个项目应该是折叠块")
        }

        if case .line(let line) = items[1] {
            XCTAssertEqual(line.type, .modified)
        } else {
            XCTFail("第二个项目应该是修改的行")
        }

        if case .collapsibleBlock(let second) = items[2] {
            XCTAssertEqual(second.lines.count, 5)
        } else {
            XCTFail("第三个项目应该是折叠块")
        }
    }
}
