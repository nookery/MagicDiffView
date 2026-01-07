#if DEBUG
import SwiftUI

/// 主题展示视图
struct ThemeShowcaseView: View {
    @State private var selectedTheme: any DiffTheme = DiffThemes.light

    var body: some View {
        VStack(spacing: 0) {
            // 主题选择器
            themeSelectorView

            // 差异视图
            MagicDiffView(
                oldText: oldCode,
                newText: newCode,
                theme: selectedTheme
            )
        }
    }
}

// MARK: - View
extension ThemeShowcaseView {
    /// 主题选择器视图
    private var themeSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(allThemes, id: \.name) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: isSelectedTheme(theme)
                    ) {
                        selectTheme(theme)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.secondary.opacity(0.1))
    }

    /// 所有可用主题
    private var allThemes: [any DiffTheme] {
        [
            DiffThemes.light,
            DiffThemes.dark,
            DiffThemes.github,
            DiffThemes.vscode,
            DiffThemes.highContrast,
            DiffThemes.soft
        ]
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

// MARK: - Action
extension ThemeShowcaseView {
    /// 选择主题
    func selectTheme(_ theme: any DiffTheme) {
        selectedTheme = theme
    }
}

// MARK: - Private Helpers
extension ThemeShowcaseView {
    /// 检查主题是否被选中
    private func isSelectedTheme(_ theme: any DiffTheme) -> Bool {
        themeName(selectedTheme) == theme.name
    }

    /// 获取主题名称
    private func themeName(_ theme: any DiffTheme) -> String {
        theme.name
    }
}

/// 主题选择按钮
struct ThemeButton: View {
    let theme: any DiffTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // 颜色预览
                HStack(spacing: 2) {
                    Circle()
                        .fill(theme.addedBackground)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(theme.removedBackground)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(theme.modifiedBackground)
                        .frame(width: 8, height: 8)
                }
                .padding(4)
                .background(theme.backgroundColor)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )

                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview("主题展示") {
    ThemeShowcaseView()
        .frame(height: 600)
        .frame(width: 600)
}
#endif
