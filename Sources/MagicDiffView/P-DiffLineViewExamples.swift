#if DEBUG
import SwiftUI

/// DiffLineView 示例预览
struct DiffLineViewExamples: View {
    var body: some View {
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
}

// MARK: - Preview

#Preview("DiffLineView Examples") {
    DiffLineViewExamples()
}
#endif
