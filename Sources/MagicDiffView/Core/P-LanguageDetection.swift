import SwiftUI

/// 语言检测和详细日志演示
struct LanguageDetectionDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "struct OldView: View {\n    var body: some View {\n        Text(\"Hello\")\n    }\n}",
            newText: "struct NewView: View {\n    @State private var message = \"Hello, World!\"\n    \n    var body: some View {\n        VStack {\n            Text(message)\n                .font(.title)\n            Button(\"Update\") {\n                message = \"Updated!\"\n            }\n        }\n        .padding()\n    }\n}",
            verbose: true  // 启用详细日志
        )
    }
}

// MARK: - Preview

#Preview("语言检测") {
    LanguageDetectionDiffView()
}
