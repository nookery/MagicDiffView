import SwiftUI

/// 差异视图中的行号区域视图
/// GitHub Desktop 风格：始终显示双列（旧行号 | 新行号）
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
        Group {
            switch displayMode {
            case .diff:
                // GitHub Desktop 风格：始终显示双列
                diffModeLineNumbers
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
        .overlay(
            separatorLine(),
            alignment: .trailing
        )
    }

    /// 统一 diff 模式的双列行号（GitHub Desktop 风格）
    private var diffModeLineNumbers: some View {
        HStack(spacing: 0) {
            // 旧行号列（删除行显示，新增行为空）
            if line.type == .removed || line.type == .unchanged || line.type == .modified {
                lineNumberText(line.oldLineNumber, color: theme.lineNumberColor)
            } else {
                // 新增行：旧行号列为空
                Text(" ")
                    .font(font)
                    .frame(width: 36, alignment: .trailing)
                    .padding(.horizontal, 4)
            }
            
            // 中间分割线
            separatorLine()
            
            // 新行号列（新增行显示，删除行为空）
            if line.type == .added || line.type == .unchanged || line.type == .modified {
                lineNumberText(line.newLineNumber, color: theme.lineNumberColor)
            } else {
                // 删除行：新行号列为空
                Text(" ")
                    .font(font)
                    .frame(width: 36, alignment: .trailing)
                    .padding(.horizontal, 4)
            }
        }
    }

    private func separatorLine() -> some View {
        Rectangle()
            .frame(width: 1)
            .foregroundColor(theme.separatorColor)
    }

    private func lineNumberText(_ number: Int?, color: Color) -> some View {
        Text(number.map(String.init) ?? "")
            .font(font)
            .foregroundColor(color)
            .frame(width: 36, alignment: .trailing)
            .padding(.horizontal, 4)
    }

    private var gutterBackgroundColor: Color {
        // GitHub Desktop 风格：行号区域的背景色跟随行类型变化
        // added 行的 gutter 也有绿色背景，deleted 行的 gutter 也有红色背景
        switch line.type {
        case .added:
            return theme.addedBackground
        case .removed:
            return theme.removedBackground
        case .modified:
            return theme.modifiedBackground
        case .unchanged:
            return theme.gutterBackground
        }
    }
}
