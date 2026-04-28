import SwiftUI

/// GitHub Desktop 风格的 Hunk Header
/// 蓝色背景横条，左侧可点击的展开/折叠按钮，中间显示行号范围
/// 参考 GitHub Desktop 的 hunk-expansion-handle 设计
struct HunkHeaderView: View {
    let header: HunkHeader
    let expansionType: HunkExpansionType
    let font: Font
    let theme: any DiffTheme
    
    /// 展开/折叠回调
    let onExpand: (HunkExpansionDirection) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧扩展按钮区域
            expansionButtons
            
            // 行号范围文本
            Text(header.contextInfo)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(theme.lineNumberColor)
                .padding(.leading, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 20)
        .background(theme.hunkHeaderBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(theme.separatorColor),
            alignment: .bottom
        )
    }
    
    /// 展开/折叠按钮（根据 expansionType 渲染）
    @ViewBuilder
    private var expansionButtons: some View {
        switch expansionType {
        case .none:
            // 不可扩展，只显示占位
            Rectangle()
                .fill(.clear)
                .frame(width: 89)
        case .up:
            // 只能向上扩展
            expandButton(direction: .up, isFullHeight: true)
        case .down:
            // 只能向下扩展
            expandButton(direction: .down, isFullHeight: true)
        case .both:
            // 可双向扩展 - 上下两个按钮各占一半高度
            VStack(spacing: 0) {
                expandButton(direction: .down, isHalf: true)
                expandButton(direction: .up, isHalf: true)
            }
            .frame(width: 89)
        case .short:
            // 短 gap，展开时会合并
            expandButton(direction: .both, isFullHeight: true)
        }
    }
    
    /// 单个扩展按钮
    private func expandButton(direction: HunkExpansionDirection, isHalf: Bool = false, isFullHeight: Bool = false) -> some View {
        Button(action: {
            onExpand(direction)
        }) {
            Image(systemName: directionIcon(direction))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.lineNumberColor.opacity(0.7))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 89, height: isHalf ? 10 : 20)
    }
    
    private func directionIcon(_ direction: HunkExpansionDirection) -> String {
        switch direction {
        case .up: return "chevron.up"
        case .down: return "chevron.down"
        case .both: return "arrow.up.arrow.down"
        }
    }
}

/// Hunk 扩展方向
public enum HunkExpansionDirection {
    case up
    case down
    case both
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        HunkHeaderView(
            header: HunkHeader(oldStartLine: 86, oldLineCount: 6, newStartLine: 89, newLineCount: 21),
            expansionType: .down,
            font: .system(.body, design: .monospaced),
            theme: DiffThemes.light,
            onExpand: { _ in }
        )
        HunkHeaderView(
            header: HunkHeader(oldStartLine: 1, oldLineCount: 10, newStartLine: 1, newLineCount: 15),
            expansionType: .both,
            font: .system(.body, design: .monospaced),
            theme: DiffThemes.light,
            onExpand: { _ in }
        )
        HunkHeaderView(
            header: HunkHeader(oldStartLine: 100, oldLineCount: 5, newStartLine: 105, newLineCount: 5),
            expansionType: .up,
            font: .system(.body, design: .monospaced),
            theme: DiffThemes.light,
            onExpand: { _ in }
        )
        Spacer()
    }
    .background(Color.white)
}
#endif
