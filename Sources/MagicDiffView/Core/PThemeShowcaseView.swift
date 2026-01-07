import SwiftUI

/// 主题展示视图
struct ThemeShowcaseView: View {
    @State private var selectedTheme: any DiffTheme = DiffThemes.light

    let oldCode = """
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

    let newCode = """
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

    var body: some View {
        VStack(spacing: 0) {
            // 主题选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ThemeButton(
                        theme: DiffThemes.light,
                        isSelected: themeName(selectedTheme) == "Light"
                    ) {
                        selectedTheme = DiffThemes.light
                    }

                    ThemeButton(
                        theme: DiffThemes.dark,
                        isSelected: themeName(selectedTheme) == "Dark"
                    ) {
                        selectedTheme = DiffThemes.dark
                    }

                    ThemeButton(
                        theme: DiffThemes.github,
                        isSelected: themeName(selectedTheme) == "GitHub"
                    ) {
                        selectedTheme = DiffThemes.github
                    }

                    ThemeButton(
                        theme: DiffThemes.vscode,
                        isSelected: themeName(selectedTheme) == "VS Code"
                    ) {
                        selectedTheme = DiffThemes.vscode
                    }

                    ThemeButton(
                        theme: DiffThemes.highContrast,
                        isSelected: themeName(selectedTheme) == "High Contrast"
                    ) {
                        selectedTheme = DiffThemes.highContrast
                    }

                    ThemeButton(
                        theme: DiffThemes.soft,
                        isSelected: themeName(selectedTheme) == "Soft"
                    ) {
                        selectedTheme = DiffThemes.soft
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color.secondary.opacity(0.1))

            // 差异视图
            MagicDiffView(
                oldText: oldCode,
                newText: newCode,
                theme: selectedTheme
            )
        }
    }

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

#Preview("主题展示") {
    ThemeShowcaseView()
}
