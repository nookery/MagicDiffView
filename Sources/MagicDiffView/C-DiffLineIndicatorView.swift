import SwiftUI

/// 差异视图中的行指示器视图
/// 参考 GitHub Desktop 的指示器样式：显示 + / - 符号
struct DiffLineIndicatorView: View {
    let line: DiffLine
    let font: Font
    let theme: any DiffTheme

    init(
        line: DiffLine,
        font: Font,
        theme: any DiffTheme = DiffThemes.light
    ) {
        self.line = line
        self.font = font
        self.theme = theme
    }

    var body: some View {
        Text(indicatorSymbol)
            .font(font)
            .foregroundColor(indicatorColor)
            .frame(width: 20, alignment: .center)
    }

    /// 根据行类型返回对应的指示器符号
    private var indicatorSymbol: String {
        switch line.type {
        case .added: return "+"
        case .removed: return "−"  // 使用 Unicode 减号字符，比连字符更美观
        case .modified: return "~"
        default: return " "
        }
    }
    
    /// 指示器颜色
    private var indicatorColor: Color {
        switch line.type {
        case .added:
            return theme.addedTextColor.opacity(0.7)
        case .removed:
            return theme.removedTextColor.opacity(0.7)
        case .modified:
            return theme.modifiedTextColor.opacity(0.7)
        default:
            return .clear
        }
    }
}
