#if DEBUG
import SwiftUI

/// 删除代码演示
struct DeletionsDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "struct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n            .padding()\n    }\n}",
            newText: ""
        )
    }
}

// MARK: - Preview

#Preview("删除代码") {
    DeletionsDiffView()
        .frame(height: 600)
}
#endif
