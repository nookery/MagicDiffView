import SwiftUI
import OSLog

/// 差异视图的主要内容组件
struct DiffContentView: View {
    public nonisolated static let emoji = "📋"

    let diffItems: [DiffItem]
    let showLineNumbers: Bool
    let font: Font
    let selectedLanguage: CodeLanguage
    let displayMode: ViewMode
    let verbose: Bool
    let theme: any DiffTheme

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(diffItems.enumerated()), id: \.offset) { index, item in
                    switch item {
                    case let .line(line):
                        diffLineItem(line)
                    case let .collapsibleBlock(block):
                        diffBlockItem(block)
                    case let .hunkHeader(header):
                        hunkHeaderItem(header)
                    }
                }
            }
        }
    }

    /// 创建差异视图中的单行项目视图
    @ViewBuilder
    private func diffLineItem(_ line: DiffLine) -> some View {
        DiffLineView(
            line: line,
            showLineNumbers: showLineNumbers,
            font: font,
            codeLanguage: selectedLanguage,
            displayMode: displayMode,
            verbose: verbose,
            theme: theme
        )
    }

    /// 差异视图中的折叠块项目
    private func diffBlockItem(_ block: CollapsibleBlock) -> some View {
        CollapsibleBlockView(
            block: block,
            showLineNumbers: showLineNumbers,
            font: font,
            displayMode: displayMode,
            codeLanguage: selectedLanguage,
            verbose: verbose,
            theme: theme
        )
    }

    /// Hunk Header 行（@@ -x,y +a,b @@）
    /// 参考 GitHub Desktop 的 hunk handle 渲染
    private func hunkHeaderItem(_ header: HunkHeader) -> some View {
        HunkHeaderView(
            header: header,
            font: font,
            theme: theme
        )
    }

    init(
        diffItems: [DiffItem],
        showLineNumbers: Bool,
        font: Font = .system(.body, design: .monospaced),
        selectedLanguage: CodeLanguage,
        displayMode: ViewMode = .diff,
        verbose: Bool = false,
        theme: any DiffTheme = DiffThemes.light
    ) {
        self.diffItems = diffItems
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.selectedLanguage = selectedLanguage
        self.displayMode = displayMode
        self.verbose = verbose
        self.theme = theme
    }
}
