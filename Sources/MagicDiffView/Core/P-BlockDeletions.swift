#if DEBUG
import SwiftUI

/// 代码块删除演示
struct BlockDeletionsDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "struct UserView: View {\n    @State private var username = \"\"\n    @State private var password = \"\"\n    \n    var body: some View {\n        VStack {\n            TextField(\"用户名\", text: $username)\n            SecureField(\"密码\", text: $password)\n            Button(\"登录\") {\n                // 处理登录逻辑\n            }\n        }\n        .padding()\n    }\n}",
            newText: "struct UserView: View {\n    @State private var username = \"\"\n    \n    var body: some View {\n        VStack {\n            TextField(\"用户名\", text: $username)\n        }\n        .padding()\n    }\n}"
        )
    }
}

// MARK: - Preview

#Preview("代码块删除") {
    BlockDeletionsDiffView()
        .frame(height: 600)
}
#endif
