import SwiftUI

/// 新增代码演示
struct AdditionsDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "",
            newText: "struct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n            .padding()\n    }\n}"
        )
    }
}

// MARK: - Preview

#Preview("新增代码") {
    AdditionsDiffView()
}
