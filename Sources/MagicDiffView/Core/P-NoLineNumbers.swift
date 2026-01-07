import SwiftUI

/// 无行号差异视图演示
struct NoLineNumbersDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "Simple text\nAnother line",
            newText: "Modified text\nAnother line\nExtra line",
            showLineNumbers: false
        )
    }
}

// MARK: - Preview

#Preview("无行号差异") {
    NoLineNumbersDiffView()
}
