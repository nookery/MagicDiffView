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
    let displayMode: MagicDiffViewMode
    let verbose: Bool
    let showIndicator: Bool
    let theme: any DiffTheme

    @State private var isHovered = false

    init(
        line: DiffLine,
        showLineNumbers: Bool,
        font: Font,
        codeLanguage: CodeLanguage,
        displayMode: MagicDiffViewMode,
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
    /// 内容视图
    private var contentView: some View {
        Group {
            if !line.content.isEmpty {
                if displayMode == .diff {
                    switch line.type {
                    case .added:
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            highlightRanges: line.highlightRanges,
                            highlightColor: theme.addedHighlightColor,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(theme.addedTextColor)
                        .padding(.leading, 4)
                    case .removed:
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            highlightRanges: line.highlightRanges,
                            highlightColor: theme.removedHighlightColor,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(theme.removedTextColor)
                        .padding(.leading, 4)
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
                        SyntaxHighlighter.highlight(
                            text: line.content,
                            rules: codeLanguage.rules,
                            verbose: verbose
                        )
                        .font(font)
                        .foregroundColor(theme.modifiedTextColor)
                        .padding(.leading, 4)
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
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
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
    #Preview("MagicDiffPreviewView") {
        MagicDiffPreviewView()
    }

    #Preview("DiffLineView Examples") {
        VStack(alignment: .leading, spacing: 12) {
            let unchanged = DiffLine(
                content: "print(\"Hello World\")",
                type: .unchanged,
                oldLineNumber: 1,
                newLineNumber: 1
            )
            let removed = DiffLine(
                content: "print(\"Old Only\")",
                type: .removed,
                oldLineNumber: 2,
                newLineNumber: nil
            )
            let added = DiffLine(
                content: "print(\"New Only\")",
                type: .added,
                oldLineNumber: nil,
                newLineNumber: 3
            )

            DiffLineView(
                line: unchanged,
                showLineNumbers: true,
                font: .system(.body, design: .monospaced),
                codeLanguage: .swift,
                displayMode: .diff,
                verbose: true
            )

            DiffLineView(
                line: removed,
                showLineNumbers: true,
                font: .system(.body, design: .monospaced),
                codeLanguage: .swift,
                displayMode: .original,
                verbose: true
            )

            DiffLineView(
                line: added,
                showLineNumbers: true,
                font: .system(.body, design: .monospaced),
                codeLanguage: .swift,
                displayMode: .modified,
                verbose: true
            )
        }
        .padding()
    }
#endif
