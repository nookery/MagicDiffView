import SwiftUI

/// GitHub Desktop 风格的行内容视图（不含行号和复选框）
/// 包含 `+`/`-` 前缀（作为内容的第一个字符）
struct DiffLineContentView: View {
    let line: DiffLine
    let font: Font
    let codeLanguage: CodeLanguage
    let displayMode: ViewMode
    let verbose: Bool
    let theme: any DiffTheme

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 0) {
            // `+`/`-` 指示符前缀（GitHub Desktop 风格）
            indicatorPrefix
            
            // 代码内容
            contentView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 20) // GitHub Desktop 标准行高
        .background(backgroundColor)
    }

    /// 行首的 `+`/`-` 指示符
    @ViewBuilder
    private var indicatorPrefix: some View {
        if displayMode == .diff {
            Text(line.type == .added ? "+" : line.type == .removed ? "−" : " ")
                .font(font)
                .foregroundColor(indicatorPrefixColor)
                .frame(width: 14, alignment: .center)
                .background(indicatorPrefixBackgroundColor)
        }
    }

    private var indicatorPrefixColor: Color {
        switch line.type {
        case .added: return theme.addedTextColor
        case .removed: return theme.removedTextColor
        case .modified: return theme.modifiedTextColor
        case .unchanged: return theme.unchangedTextColor
        }
    }

    private var indicatorPrefixBackgroundColor: Color {
        // 修复：直接使用行背景色，确保 `+`/`-` 符号背景与代码区背景完全融合
        // 这解决了 GitHub Desktop 中指示符背景与行背景不一致的视觉问题
        backgroundColor
    }

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
            Text(" ")
                .font(font)
        }
    }

    @ViewBuilder
    private func highlightedContent(
        rules: [SyntaxHighlighter.HighlightRule],
        textColor: Color,
        charHighlightColor: Color
    ) -> some View {
        if let charRanges = line.charHighlightRanges, !charRanges.isEmpty {
            Text(buildCharHighlightedAttributedString(
                textColor: textColor,
                charHighlightColor: charHighlightColor
            ))
        } else {
            SyntaxHighlighter.highlight(
                text: line.content,
                rules: rules,
                highlightRanges: line.highlightRanges,
                highlightColor: charHighlightColor,
                verbose: verbose
            )
            .font(font)
            .foregroundColor(textColor)
        }
    }

    private func buildCharHighlightedAttributedString(
        textColor: Color,
        charHighlightColor: Color
    ) -> AttributedString {
        var attrString = AttributedString(line.content)
        attrString.font = font
        attrString.foregroundColor = textColor

        if let charRanges = line.charHighlightRanges {
            let sortedRanges = charRanges.sorted { $0.location < $1.location }
            for range in sortedRanges where range.length > 0 {
                let startIdx = attrString.index(attrString.startIndex, offsetByCharacters: range.location)
                let endIdx = attrString.index(startIdx, offsetByCharacters: range.length)
                attrString[startIdx..<endIdx].backgroundColor = charHighlightColor
            }
        }

        return attrString
    }

    private var backgroundColor: Color {
        switch line.type {
        case .added: return theme.addedBackground
        case .removed: return theme.removedBackground
        case .unchanged: return theme.unchangedBackground
        case .modified: return theme.modifiedBackground
        }
    }
}
