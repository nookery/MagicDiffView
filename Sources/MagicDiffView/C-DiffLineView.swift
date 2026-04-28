import OSLog
import SwiftUI
#if os(iOS)
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif

/// 差异视图中的单行视图
struct DiffLineView: View {
    public nonisolated static let emoji = "📄"

    let line: DiffLine
    let showLineNumbers: Bool
    let font: Font
    let codeLanguage: CodeLanguage
    let displayMode: ViewMode
    let verbose: Bool
    let showIndicator: Bool
    let theme: any DiffTheme

    @State private var isHovered = false

    init(
        line: DiffLine,
        showLineNumbers: Bool,
        font: Font,
        codeLanguage: CodeLanguage,
        displayMode: ViewMode,
        verbose: Bool,
        showIndicator: Bool = false,
        theme: any DiffTheme = DiffThemes.light
    ) {
        self.line = line
        self.showLineNumbers = showLineNumbers
        self.font = font
        self.codeLanguage = codeLanguage
        self.displayMode = displayMode
        self.verbose = verbose
        self.showIndicator = showIndicator
        self.theme = theme
    }

    var body: some View {
        HStack(spacing: 0) {
            if showLineNumbers {
                DiffLineNumberView(
                    line: line,
                    displayMode: displayMode,
                    font: font,
                    theme: theme
                )
            }

            if showIndicator {
                DiffLineIndicatorView(
                    line: line,
                    font: font,
                    theme: theme
                )
            }

            contentView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 20) // GitHub Desktop 标准行高
        .background(backgroundColor)
        #if os(macOS)
            .onHover { hovering in
                isHovered = hovering
            }
        #endif
            .contextMenu {
                Button(action: {
                    copyLine()
                }) {
                    Label("复制行", systemImage: "doc.on.doc")
                }

                if !line.content.isEmpty {
                    Button(action: {
                        copyContent(line.content)
                    }) {
                        Label("复制内容", systemImage: "text.cursor")
                    }
                }
            }
    }
}

// MARK: - Private Helpers
extension DiffLineView {
    /// 内容视图（支持字符级高亮）
    @ViewBuilder
    private var contentView: some View {
        if !line.content.isEmpty {
            if displayMode == .diff {
                switch line.type {
                case .added:
                    highlightedContent(
                        rules: codeLanguage.rules,
                        textColor: theme.addedTextColor,
                        charHighlightColor: theme.addedHighlightColor
                    )
                case .removed:
                    highlightedContent(
                        rules: codeLanguage.rules,
                        textColor: theme.removedTextColor,
                        charHighlightColor: theme.removedHighlightColor
                    )
                case .unchanged:
                    SyntaxHighlighter.highlight(
                        text: line.content,
                        rules: codeLanguage.rules,
                        verbose: verbose
                    )
                    .font(font)
                    .foregroundColor(theme.unchangedTextColor)
                case .modified:
                    highlightedContent(
                        rules: codeLanguage.rules,
                        textColor: theme.modifiedTextColor,
                        charHighlightColor: theme.removedHighlightColor
                    )
                }
            } else {
                SyntaxHighlighter.highlight(
                    text: line.content,
                    rules: codeLanguage.rules,
                    verbose: verbose
                )
                .font(font)
                .foregroundColor(theme.unchangedTextColor)
            }
        } else {
            Text("")
                .font(font)
        }
    }

    /// 带字符级高亮的内容视图
    /// 参考 GitHub Desktop 的行内差异渲染
    @ViewBuilder
    private func highlightedContent(
        rules: [SyntaxHighlighter.HighlightRule],
        textColor: Color,
        charHighlightColor: Color
    ) -> some View {
        if let charRanges = line.charHighlightRanges, !charRanges.isEmpty {
            // 使用 AttributedString 精确渲染字符级高亮
            Text(buildCharHighlightedAttributedString(
                textColor: textColor,
                charHighlightColor: charHighlightColor
            ))
            .padding(.leading, 4)
        } else {
            // 无字符级高亮：使用原有的语法高亮 + 行级高亮
            SyntaxHighlighter.highlight(
                text: line.content,
                rules: rules,
                highlightRanges: line.highlightRanges,
                highlightColor: charHighlightColor,
                verbose: verbose
            )
            .font(font)
            .foregroundColor(textColor)
            .padding(.leading, 4)
        }
    }

    /// 构建带字符级高亮的 AttributedString
    private func buildCharHighlightedAttributedString(
        textColor: Color,
        charHighlightColor: Color
    ) -> AttributedString {
        guard let charRanges = line.charHighlightRanges, !charRanges.isEmpty else {
            var attrString = AttributedString(line.content)
            attrString.font = font
            attrString.foregroundColor = textColor
            return attrString
        }
        
        var attrString = AttributedString(line.content)
        attrString.font = font
        attrString.foregroundColor = textColor

        // 按位置排序范围，避免重叠问题
        let sortedRanges = charRanges.sorted { $0.location < $1.location }

        for range in sortedRanges where range.length > 0 {
            let startIdx = attrString.index(attrString.startIndex, offsetByCharacters: range.location)
            let endIdx = attrString.index(startIdx, offsetByCharacters: range.length)
            // 设置高亮背景色（直接使用主题颜色，透明度已由主题定义）
            attrString[startIdx..<endIdx].backgroundColor = charHighlightColor
        }

        return attrString
    }

    /// 背景颜色
    private var backgroundColor: Color {
        switch line.type {
        case .added:
            return theme.addedBackground
        case .removed:
            return theme.removedBackground
        case .unchanged:
            return theme.unchangedBackground
        case .modified:
            return theme.modifiedBackground
        }
    }
}

// MARK: - Action
extension DiffLineView {
    /// 复制整行
    func copyLine() {
        if !line.content.isEmpty {
            #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(line.content, forType: .string)
            #else
            UIPasteboard.general.string = line.content
            #endif

            if verbose {
                os_log("复制行: \(line.content)")
            }
        }
    }

    /// 复制内容
    func copyContent(_ content: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        #else
        UIPasteboard.general.string = content
        #endif

        if verbose {
            os_log("复制内容: \(content)")
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("DiffLineView Examples") {
    DiffLineViewExamples()
}
#endif
