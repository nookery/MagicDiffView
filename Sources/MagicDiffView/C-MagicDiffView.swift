import OSLog
import SwiftUI

/// 用于比较两个字符串差异的视图组件，类似GitHub Desktop的diff视图
///
/// `MagicDiffView` 提供了一个直观的界面来展示两个文本之间的差异，
/// 支持行级别的比较，并用不同颜色标识添加、删除和修改的内容。
///
/// 基本使用示例：
/// ```swift
/// MagicDiffView(
///     oldText: "Hello World\nThis is line 2",
///     newText: "Hello Swift\nThis is line 2\nNew line 3"
/// )
/// ```
///
/// 支持主题配置：
/// ```swift
/// MagicDiffView(
///     oldText: oldCode,
///     newText: newCode,
///     initialTheme: .github
/// )
/// ```
///
/// 自动主题模式：
/// ```swift
/// MagicDiffView(
///     oldText: oldCode,
///     newText: newCode,
///     initialTheme: .auto  // 根据系统设置自动选择浅色或深色主题
/// )
/// ```
///
/// 解析Git diff输出：
/// ```swift
/// MagicDiffView(
///     diffOutput: """
///     diff --git a/file.txt b/file.txt
///     @@ -1,3 +1,3 @@
///      Line 1
///     -Line 2 old
///     +Line 2 new
///      Line 3
///     """
/// )
/// ```
public struct MagicDiffView: View {
    public nonisolated static let emoji = "🖥️"

    // 配置属性
    let oldText: String?
    let newText: String?
    let diffOutput: String?
    let diffLines: [DiffLine]?
    let showLineNumbers: Bool
    let showCheckboxes: Bool
    let font: Font
    let enableCollapsing: Bool
    let minUnchangedLines: Int
    let verbose: Bool
    let language: CodeLanguage

    // 状态管理
    @State private var selectedView: ViewMode = .diff
    @State private var selectedTheme: ThemePreset
    @State private var isInitialized: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    // Diff 计算结果缓存（避免在 body 中重复计算导致主线程阻塞）
    @State private var cachedDiffItems: [DiffItem] = []
    @State private var cachedOriginalItems: [DiffItem] = []
    @State private var cachedModifiedItems: [DiffItem] = []
    @State private var reconstructedOldText: String = ""
    @State private var reconstructedNewText: String = ""
    @State private var isDiffComputing: Bool = false

    // 当前主题（从 selectedTheme 计算）
    private var theme: any DiffTheme {
        selectedTheme.theme(for: colorScheme)
    }

    // 复制状态管理
    @State private var copyState: CopyState = .idle
    @State private var copyMessage: String = ""

    /// 创建差异比较视图
    /// - Parameters:
    ///   - oldText: 原始文本
    ///   - newText: 新文本
    ///   - showLineNumbers: 是否显示行号，默认为 true
    ///   - showCheckboxes: 是否显示复选框列（用于选择提交行），默认为 false
    ///   - font: 文本字体，默认为等宽字体
    ///   - enableCollapsing: 是否启用折叠功能，默认为 true
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    ///   - verbose: 是否启用详细日志，默认为 false
    ///   - initialTheme: 初始主题，默认为自动（根据系统设置自动选择）
    public init(
        oldText: String,
        newText: String,
        showLineNumbers: Bool = true,
        showCheckboxes: Bool = false,
        font: Font = .system(.body, design: .monospaced),
        enableCollapsing: Bool = true,
        minUnchangedLines: Int = 3,
        verbose: Bool = false,
        initialTheme: ThemePreset = .auto
    ) {
        if verbose {
            os_log("oldText: \(oldText.count) newText: \(newText.count)")
        }

        self.oldText = oldText
        self.newText = newText
        self.diffOutput = nil
        self.diffLines = nil
        self.showLineNumbers = showLineNumbers
        self.showCheckboxes = showCheckboxes
        self.font = font
        self.enableCollapsing = enableCollapsing
        self.minUnchangedLines = minUnchangedLines
        self.verbose = verbose
        self.language = SyntaxHighlighter.detectLanguage(newText)
        self._selectedTheme = State(initialValue: initialTheme)

        if verbose {
            os_log("🔍 初始化完成")
        }
    }

    /// 创建差异比较视图（解析Git Diff输出）
    /// - Parameters:
    ///   - diffOutput: Git diff 格式的文本输出
    ///   - showLineNumbers: 是否显示行号，默认为 true
    ///   - showCheckboxes: 是否显示复选框列（用于选择提交行），默认为 false
    ///   - font: 文本字体，默认为等宽字体
    ///   - enableCollapsing: 是否启用折叠功能，默认为 true
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    ///   - verbose: 是否启用详细日志，默认为 false
    ///   - initialTheme: 初始主题，默认为自动（根据系统设置自动选择）
    public init(
        diffOutput: String,
        showLineNumbers: Bool = true,
        showCheckboxes: Bool = false,
        font: Font = .system(.body, design: .monospaced),
        enableCollapsing: Bool = true,
        minUnchangedLines: Int = 3,
        verbose: Bool = false,
        initialTheme: ThemePreset = .auto
    ) {
        if verbose {
            os_log("diffOutput: \(diffOutput.count)")
        }

        let parsedDiffLines = MyersDiffAlgorithm.parseUnifiedDiffSafely(diffOutput)

        self.oldText = nil
        self.newText = nil
        self.diffOutput = diffOutput
        self.diffLines = parsedDiffLines
        self.showLineNumbers = showLineNumbers
        self.showCheckboxes = showCheckboxes
        self.font = font
        self.enableCollapsing = enableCollapsing
        self.minUnchangedLines = minUnchangedLines
        self.verbose = verbose

        // 从diff内容中检测语言
        let sampleContent = parsedDiffLines.compactMap { line in
            switch line.type {
            case .added, .unchanged:
                return line.content
            case .removed, .modified:
                return nil
            }
        }.joined(separator: "\n")
        self.language = SyntaxHighlighter.detectLanguage(sampleContent)

        self._selectedTheme = State(initialValue: initialTheme)

        if verbose {
            os_log("🔍 Diff解析完成，差异行数: \(parsedDiffLines.count)")
        }
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 顶部工具栏
                DiffToolbar(
                    selectedView: $selectedView,
                    selectedTheme: $selectedTheme,
                    copyState: $copyState,
                    oldText: oldText ?? reconstructedOldText,
                    newText: newText ?? reconstructedNewText,
                    verbose: verbose,
                    onCopy: copyToClipboard
                )

                // 主要内容区域
                Group {
                    if isDiffComputing && cachedDiffItems.isEmpty {
                        // 首次计算中，显示轻量占位
                        Color.clear
                    } else {
                        switch selectedView {
                        case .diff:
                            DiffContentView(
                                diffItems: cachedDiffItems,
                                showLineNumbers: showLineNumbers,
                                showCheckboxes: showCheckboxes,
                                font: font,
                                selectedLanguage: language,
                                displayMode: .diff,
                                verbose: verbose,
                                theme: theme
                            )
                        case .sideBySide:
                            SideBySideDiffView(
                                diffItems: cachedDiffItems,
                                showLineNumbers: showLineNumbers,
                                font: font,
                                selectedLanguage: language,
                                theme: theme,
                                verbose: verbose
                            )
                        case .original:
                            DiffContentView(
                                diffItems: cachedOriginalItems,
                                showLineNumbers: showLineNumbers,
                                showCheckboxes: showCheckboxes,
                                font: font,
                                selectedLanguage: language,
                                displayMode: .original,
                                verbose: verbose,
                                theme: theme
                            )
                        case .modified:
                            DiffContentView(
                                diffItems: cachedModifiedItems,
                                showLineNumbers: showLineNumbers,
                                showCheckboxes: showCheckboxes,
                                font: font,
                                selectedLanguage: language,
                                displayMode: .modified,
                                verbose: verbose,
                                theme: theme
                            )
                        }
                    }
                }
                .background(theme.backgroundColor)
                .animation(.easeInOut(duration: 0.15), value: isDiffComputing)
            }

            // 浮动提示消息
            CopyToast(copyState: copyState, message: copyMessage)
        }
        .task(id: taskIdentity) {
            await computeAllDiffItems()
        }
    }

    /// 用于触发 task 重新计算的标识，当文本内容或折叠配置变化时自动更新
    private var taskIdentity: String {
        "\(oldText ?? "")\n---SEPARATOR---\n\(newText ?? "")\n---SEPARATOR---\n\(diffOutput ?? "")\n---SEPARATOR---\n\(enableCollapsing)\n---SEPARATOR---\n\(minUnchangedLines)"
    }

    /// 异步计算所有 DiffItem 并缓存结果，避免在 body 中同步执行重计算阻塞主线程
    private func computeAllDiffItems() async {
        isDiffComputing = true

        // 将重计算放到后台线程，避免阻塞 UI
        let oldText = self.oldText
        let newText = self.newText
        let diffLines = self.diffLines
        let enableCollapsing = self.enableCollapsing
        let minUnchangedLines = self.minUnchangedLines

        let (items, computedOldText, computedNewText, originalItems, modifiedItems) = await Task.detached(priority: .userInitiated) {
            // 计算在后台线程执行
            return Self.computeDiffItemsInBackground(
                oldText: oldText,
                newText: newText,
                diffLines: diffLines,
                enableCollapsing: enableCollapsing,
                minUnchangedLines: minUnchangedLines
            )
        }.value

        // 回到主线程更新缓存
        self.cachedDiffItems = items
        self.reconstructedOldText = computedOldText
        self.reconstructedNewText = computedNewText
        self.cachedOriginalItems = originalItems
        self.cachedModifiedItems = modifiedItems
        self.isDiffComputing = false

        if verbose {
            os_log("✅ Diff 异步计算完成，差异项目数: \(items.count)")
        }
    }

    /// 在后台线程执行所有重计算（nonisolated 纯计算，不涉及 UI）
    nonisolated private static func computeDiffItemsInBackground(
        oldText: String?,
        newText: String?,
        diffLines: [DiffLine]?,
        enableCollapsing: Bool,
        minUnchangedLines: Int
    ) -> (diffItems: [DiffItem], oldText: String, newText: String, originalItems: [DiffItem], modifiedItems: [DiffItem]) {
        var computedDiffItems: [DiffItem] = []
        var computedOldText: String = oldText ?? ""
        var computedNewText: String = newText ?? ""

        // 如果有预解析的 diffLines，直接使用
        if let diffLines = diffLines {
            if enableCollapsing {
                computedDiffItems = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: minUnchangedLines)
            } else {
                computedDiffItems = diffLines.map { .line($0) }
            }

            // 重建旧文本和新文本（用于 diffOutput 模式）
            computedOldText = diffLines.compactMap { line in
                switch line.type {
                case .unchanged, .removed: return line.content
                case .added, .modified: return nil
                }
            }.joined(separator: "\n")

            computedNewText = diffLines.compactMap { line in
                switch line.type {
                case .unchanged, .added: return line.content
                case .removed, .modified: return nil
                }
            }.joined(separator: "\n")
        } else {
            // 处理 oldText/newText 模式
            guard let old = oldText, let new = newText else {
                return ([], "", "", [], [])
            }

            computedOldText = old
            computedNewText = new

            let oldLines = old.isEmpty ? [] : old.components(separatedBy: .newlines)
            let newLines = new.isEmpty ? [] : new.components(separatedBy: .newlines)

            let lines = DiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

            if enableCollapsing {
                computedDiffItems = DiffAlgorithm.organizeDiffItems(from: lines, minUnchangedLines: minUnchangedLines)
            } else {
                computedDiffItems = lines.map { .line($0) }
            }
        }

        // 预计算 original 和 modified 视图的 DiffItems
        let originalItems = Self.createDiffItemsFromTextStatic(computedOldText)
        let modifiedItems = Self.createDiffItemsFromTextStatic(computedNewText)

        return (computedDiffItems, computedOldText, computedNewText, originalItems, modifiedItems)
    }

    /// 纯文本转 DiffItem（静态版本，可在后台线程调用）
    nonisolated private static func createDiffItemsFromTextStatic(_ text: String) -> [DiffItem] {
        let lines = text.isEmpty ? [] : text.components(separatedBy: .newlines)
        return lines.enumerated().map { index, content in
            DiffLine(
                content: content,
                type: .unchanged,
                oldLineNumber: index + 1,
                newLineNumber: index + 1
            )
        }.map { DiffItem.line($0) }
    }

    /// 复制文本到剪贴板
    /// - Parameter text: 要复制的文本内容
    private func copyToClipboard(text: String) {
        if verbose {
            os_log("开始复制文本到剪贴板")
        }

        // 设置复制中状态
        withAnimation(.easeInOut(duration: 0.1)) {
            copyState = .copying
        }

        // 模拟复制操作的延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            #else
            UIPasteboard.general.string = text
            #endif

            if verbose {
                os_log("文本已复制到剪贴板")
            }

            // 复制成功
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                copyState = .success
                copyMessage = "内容已复制到剪贴板"
            }

            // 2秒后重置状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    copyState = .idle
                    copyMessage = ""
                }
                if verbose {
                    os_log("复制状态已重置")
                }
            }
        }
    }

}

