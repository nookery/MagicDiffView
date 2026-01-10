import SwiftUI

/// 差异视图中的行号区域视图
struct DiffLineNumberView: View {
    let line: DiffLine
    let displayMode: ViewMode
    let font: Font
    let theme: any DiffTheme

    init(
        line: DiffLine,
        displayMode: ViewMode,
        font: Font,
        theme: any DiffTheme = DiffThemes.light
    ) {
        self.line = line
        self.displayMode = displayMode
        self.font = font
        self.theme = theme
    }

    var body: some View {
        HStack(spacing: 0) {
            switch displayMode {
            case .diff:
                lineNumberText(line.oldLineNumber, color: theme.lineNumberColor)
                separatorLine()
                lineNumberText(line.newLineNumber, color: theme.lineNumberColor)
            case .sideBySide:
                // 并排视图不使用此组件
                EmptyView()
            case .original:
                lineNumberText(line.oldLineNumber, color: theme.lineNumberColor)
            case .modified:
                lineNumberText(line.newLineNumber, color: theme.lineNumberColor)
            }
        }
        .padding(.horizontal, 0)
        .background(gutterBackgroundColor)
        .frame(maxHeight: .infinity)
        // 在行号区域右侧添加垂直分割线，分隔行号和代码内容区域
        .overlay(
            separatorLine(),
            alignment: .trailing  // 对齐到行号区域右侧
        )
    }

    /// 创建统一的垂直分割线
    private func separatorLine() -> some View {
        Rectangle()
            .frame(width: 1)
            .foregroundColor(theme.separatorColor)
    }

    /// 生成行号文本视图
    private func lineNumberText(_ number: Int?, color: Color) -> some View {
        Text(number.map(String.init) ?? "")
            .font(font)
            .foregroundColor(color)
            .frame(width: 36, alignment: .trailing)
            .padding(.horizontal, 4)
    }

    /// 行号区域背景颜色
    private var gutterBackgroundColor: Color {
        switch line.type {
        case .added:
            return theme.addedBackground.opacity(0.5) // 行号区域使用更淡的背景色
        case .removed:
            return theme.removedBackground.opacity(0.5)
        case .unchanged:
            return theme.gutterBackground
        case .modified:
            return theme.modifiedBackground.opacity(0.5)
        }
    }
}
