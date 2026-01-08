import os
import SwiftUI

/// 差异视图的工具栏组件
struct DiffToolbar: View {
    public nonisolated static let emoji = "🔧"

    @Binding var selectedView: ViewMode
    @Binding var selectedTheme: ThemePreset
    @Binding var copyState: CopyState

    let oldText: String
    let newText: String
    var verbose = false
    var onCopy: (String) -> Void

    var body: some View {
        HStack {
            // 左侧：视图切换选择器和主题选择器
            HStack(spacing: 16) {
                // 视图切换选择器
                Picker("", selection: $selectedView) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 300)

                // 主题选择器
                Menu {
                    ForEach(ThemePreset.allCases) { theme in
                        Button(action: {
                            selectedTheme = theme
                        }) {
                            HStack {
                                Text(theme.displayName)
                                if selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "paintpalette")
                        Text(selectedTheme.displayName)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
            }

            Spacer()

            // 右侧：复制按钮（仅在文本视图时显示）
            if selectedView != .diff {
                MagicDiffCopyButton(
                    copyState: copyState,
                    action: {
                        let textToCopy = selectedView == .original ? oldText : newText
                        onCopy(textToCopy)
                    }
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.05))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.secondary.opacity(0.3)),
            alignment: .bottom
        )
    }
}

#Preview {
    DiffToolbar(
        selectedView: .constant(.diff),
        selectedTheme: .constant(.light),
        copyState: .constant(.idle),
        oldText: "Hello World",
        newText: "Hello Swift",
        onCopy: { _ in }
    )
}
