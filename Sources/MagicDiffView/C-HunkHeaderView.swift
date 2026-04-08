import SwiftUI

/// Hunk Header 视图组件
///
/// 渲染 unified diff 的 hunk header 行（如 `@@ -1,4 +1,6 @@ func hello()`），
/// 参考 GitHub Desktop 的 hunk handle 样式：
/// - 使用 theme 的 highlightBackground 背景色
/// - 显示上下文信息（行号范围 + 函数名等）
/// - 居中显示，带分割线
struct HunkHeaderView: View {
    let header: HunkHeader
    let font: Font
    let theme: any DiffTheme

    var body: some View {
        HStack(spacing: 0) {
            // 行号区域占位（与 DiffLineNumberView 对齐）
            if true {
                HStack(spacing: 0) {
                    Text(header.toDiffLineRepresentation())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(theme.lineNumberColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                }
                .frame(width: 88) // 与 diff 模式的行号区域宽度对齐
                .background(theme.gutterBackground.opacity(0.5))
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(theme.separatorColor),
                    alignment: .trailing
                )
            }

            // 分割线图标
            HStack(spacing: 6) {
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .font(.system(size: 9))
                    .foregroundColor(theme.lineNumberColor.opacity(0.6))
            }
            .frame(width: 40)
            .background(theme.gutterBackground.opacity(0.3))

            // 空内容区域
            Color.clear.frame(maxWidth: .infinity)
        }
        .background(theme.highlightBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(theme.separatorColor.opacity(0.3)),
            alignment: .bottom
        )
    }

    init(header: HunkHeader, font: Font, theme: any DiffTheme) {
        self.header = header
        self.font = font
        self.theme = theme
    }
}
