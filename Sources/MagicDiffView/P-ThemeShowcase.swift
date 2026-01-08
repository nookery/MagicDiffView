#if DEBUG
import SwiftUI

/// 主题展示视图 - 用于预览所有可用的主题
struct ThemeShowcaseView: View {
    var body: some View {
        MagicDiffView(
            oldText: oldCode,
            newText: newCode
        )
    }

    /// 演示代码 - 旧版本
    private var oldCode: String {
        """
        struct User {
            let id: Int
            let name: String
            let email: String

            init(id: Int, name: String, email: String) {
                self.id = id
                self.name = name
                self.email = email
            }
        }
        """
    }

    /// 演示代码 - 新版本
    private var newCode: String {
        """
        struct User {
            let id: Int
            let name: String
            let email: String
            let avatarURL: URL?

            init(id: Int, name: String, email: String, avatarURL: URL? = nil) {
                self.id = id
                self.name = name
                self.email = email
                self.avatarURL = avatarURL
            }

            var displayName: String {
                name.isEmpty ? "Unknown" : name
            }
        }
        """
    }
}

// MARK: - Preview

#Preview("主题展示") {
    ThemeShowcaseView()
        .frame(height: 600)
        .frame(width: 600)
}
#endif
