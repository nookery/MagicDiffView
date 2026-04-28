import SwiftUI
import OSLog

/// 差异视图的主要内容组件
/// 参考 GitHub Desktop 的布局：复选框列 + 彩色指示条 + 行号列 + 内容
struct DiffContentView: View {
    public nonisolated static let emoji = "📋"

    let diffItems: [DiffItem]
    let showLineNumbers: Bool
    let showCheckboxes: Bool
    let font: Font
    let selectedLanguage: CodeLanguage
    let displayMode: ViewMode
    let verbose: Bool
    let theme: any DiffTheme

    @State private var selectedLines: Set<Int> = []
    @State private var expandedHunks: Set<Int> = []

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(diffItems.enumerated()), id: \.offset) { index, item in
                    switch item {
                    case let .line(line):
                        diffLineItem(line, globalIndex: index)
                    case let .collapsibleBlock(block):
                        diffBlockItem(block)
                    case let .hunkHeader(header, expansionType):
                        hunkHeaderItem(header, expansionType: expansionType, hunkIndex: index)
                    }
                }
            }
        }
    }

    /// GitHub Desktop 风格的行布局：
    /// [指示条] [行号] | [内容]  (默认)
    /// [复选框] [指示条] [行号] | [内容]  (showCheckboxes=true)
    @ViewBuilder
    private func diffLineItem(_ line: DiffLine, globalIndex: Int) -> some View {
        HStack(spacing: 0) {
            // 1. 复选框列（可选，默认隐藏）
            if showCheckboxes {
                checkboxColumn(for: line, index: globalIndex)
            }
            
            // 2. 彩色指示竖线（GitHub Desktop 标志性设计）
            Rectangle()
                .fill(indicatorBarColor(for: line))
                .frame(width: 3)
            
            // 3. 行号列
            if showLineNumbers {
                DiffLineNumberView(
                    line: line,
                    displayMode: displayMode,
                    font: font,
                    theme: theme
                )
            }
            
            // 4. 内容区域
            DiffLineContentView(
                line: line,
                font: font,
                codeLanguage: selectedLanguage,
                displayMode: displayMode,
                verbose: verbose,
                theme: theme
            )
        }
    }
    
    // MARK: - Checkbox Column
    
    @ViewBuilder
    private func checkboxColumn(for line: DiffLine, index: Int) -> some View {
        Button(action: {
            toggleSelection(for: index)
        }) {
            ZStack {
                checkboxBackgroundColor(for: line, index: index)
                
                if selectedLines.contains(index) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                } else if line.type != .unchanged {
                    Image(systemName: "square")
                        .font(.system(size: 11))
                        .foregroundColor(line.type == .added ? theme.addedTextColor : theme.removedTextColor)
                        .opacity(0.5)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 28, height: 20)
    }
    
    private func checkboxBackgroundColor(for line: DiffLine, index: Int) -> Color {
        if selectedLines.contains(index) {
            return Color.blue
        }
        switch line.type {
        case .added:
            return theme.addedBackground.opacity(0.6)
        case .removed:
            return theme.removedBackground.opacity(0.6)
        case .modified:
            return theme.modifiedBackground.opacity(0.6)
        case .unchanged:
            return .clear
        }
    }
    
    private func toggleSelection(for index: Int) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if selectedLines.contains(index) {
                selectedLines.remove(index)
            } else {
                selectedLines.insert(index)
            }
        }
    }
    
    private func indicatorBarColor(for line: DiffLine) -> Color {
        switch line.type {
        case .added:
            return theme.addedHighlightColor.opacity(0.8)
        case .removed:
            return theme.removedHighlightColor.opacity(0.8)
        case .modified:
            return theme.modifiedBackground.opacity(0.8)
        case .unchanged:
            return .clear
        }
    }

    /// 差异视图中的折叠块项目
    private func diffBlockItem(_ block: CollapsibleBlock) -> some View {
        CollapsibleBlockView(
            block: block,
            showLineNumbers: showLineNumbers,
            showCheckboxes: showCheckboxes,
            font: font,
            displayMode: displayMode,
            codeLanguage: selectedLanguage,
            verbose: verbose,
            theme: theme
        )
    }

    /// Hunk Header 行（@@ -x,y +a,b @@）
    /// 参考 GitHub Desktop：蓝色背景，可点击展开/折叠
    private func hunkHeaderItem(_ header: HunkHeader, expansionType: HunkExpansionType, hunkIndex: Int) -> some View {
        HunkHeaderView(
            header: header,
            expansionType: expansionType,
            font: font,
            theme: theme,
            onExpand: { direction in
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedHunks.contains(hunkIndex) {
                        expandedHunks.remove(hunkIndex)
                    } else {
                        expandedHunks.insert(hunkIndex)
                    }
                }
            }
        )
    }

    init(
        diffItems: [DiffItem],
        showLineNumbers: Bool,
        showCheckboxes: Bool = false,
        font: Font = .system(.body, design: .monospaced),
        selectedLanguage: CodeLanguage,
        displayMode: ViewMode = .diff,
        verbose: Bool = false,
        theme: any DiffTheme = DiffThemes.light
    ) {
        self.diffItems = diffItems
        self.showLineNumbers = showLineNumbers
        self.showCheckboxes = showCheckboxes
        self.font = font
        self.selectedLanguage = selectedLanguage
        self.displayMode = displayMode
        self.verbose = verbose
        self.theme = theme
    }
}
