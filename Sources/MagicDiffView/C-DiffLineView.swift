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
                    font: font
                )
            }

            contentView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .padding(.leading, 4)
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
                .padding(.leading, 4)
            }
        } else {
            Text("")
                .font(font)
                .padding(.leading, 4)
        }
    }

    /// 带字符级高亮的内容视图
    @ViewBuilder
    private func highlightedContent(
        rules: [SyntaxHighlighter.HighlightRule],
        textColor: Color,
        charHighlightColor: Color
    ) -> some View {
        if let charRanges = line.charHighlightRanges, !charRanges.isEmpty {
            // 有字符级高亮范围：先渲染语法高亮文本，再叠加字符级高亮背景
            Text(line.content)
                .font(font)
                .foregroundColor(textColor)
                .padding(.leading, 4)
                .overlay(alignment: .leading) {
                    HStack(spacing: 0) {
                        // 字符级高亮前的空白
                        if let firstRange = charRanges.first, firstRange.location > 0 {
                            Text(String(repeating: " ", count: firstRange.location))
                                .font(font)
                                .hidden()
                                .frame(width: charWidth * CGFloat(firstRange.location))
                        }
                        // 字符级高亮部分
                        ForEach(Array(charRanges.enumerated()), id: \.offset) { _, range in
                            if range.location < line.content.count {
                                let prefix = String(repeating: " ", count: range.location)
                                let highlighted = String(line.content.prefix(range.location + range.length).dropFirst(range.location))
                                Text(prefix + highlighted)
                                    .font(font)
                                    .hidden()
                                    .frame(width: charWidth * CGFloat(range.length))
                                    .padding(.vertical, 1)
                                    .background(charHighlightColor.opacity(0.35))
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.leading, 4)
                }
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

    /// 单个等宽字符的大致宽度
    private var charWidth: CGFloat {
        7.22 // 近似值，monospaced font 下的平均字符宽度
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
