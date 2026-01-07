import SwiftUI

/// 基础差异视图演示
struct BasicDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "if let view = self.view {\n    ZStack {\n        // 必须加载，其内部3才能加载\n        view\n            .frame(maxWidth: .infinity)\n            .frame(maxHeight: .infinity)\n            .opacity(self.isReady && self.viewReady ? 1 : 0)\n    }\n    \n    if !self.isReady || !self.viewReady {\n        MagicLoading()\n    }\n} else {\n    MagicLoading()\n}",
            newText: "ZStack {\n    if let view = self.view {\n        // 必须加载，其内部3才能加载\n        view\n            .frame(maxWidth: .infinity)\n            .frame(maxHeight: .infinity)\n            .opacity(self.isReady && self.viewReady ? 1 : 0)\n    }\n    \n    if !self.isReady || !self.viewReady {\n        MagicLoading()\n    }\n}"
        )
    }
}

// MARK: - Preview

#Preview("基础差异") {
    BasicDiffView()
        .frame(height: 600)
}
