import SwiftUI

/// 折叠功能演示
struct CollapsingDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    @State private var name = \"\"\n    @State private var isEnabled = true\n    @State private var items: [String] = []\n    \n    var body: some View {\n        VStack {\n            Text(\"Hello, World!\")\n            Text(\"Counter: \\(count)\")\n            Button(\"Increment\") {\n                count += 1\n            }\n            TextField(\"Name\", text: $name)\n            Toggle(\"Enabled\", isOn: $isEnabled)\n            \n            List(items, id: \\.self) { item in\n                Text(item)\n            }\n            \n            Button(\"Add Item\") {\n                items.append(\"Item \\(items.count + 1)\")\n            }\n        }\n        .padding()\n    }\n}",
            newText: "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    @State private var name = \"\"\n    @State private var isEnabled = true\n    @State private var items: [String] = []\n    @State private var showAlert = false\n    \n    var body: some View {\n        VStack {\n            Text(\"Hello, SwiftUI!\")\n            Text(\"Counter: \\(count)\")\n            Button(\"Increment\") {\n                count += 1\n                if count > 10 {\n                    showAlert = true\n                }\n            }\n            TextField(\"Name\", text: $name)\n            Toggle(\"Enabled\", isOn: $isEnabled)\n            \n            List(items, id: \\.self) { item in\n                Text(item)\n            }\n            \n            Button(\"Add Item\") {\n                items.append(\"Item \\(items.count + 1)\")\n            }\n        }\n        .padding()\n        .alert(\"Count is high!\", isPresented: $showAlert) {\n            Button(\"OK\") { }\n        }\n    }\n}",
            enableCollapsing: true,
            minUnchangedLines: 3
        )
    }
}

// MARK: - Preview

#Preview("折叠功能") {
    CollapsingDiffView()
}
