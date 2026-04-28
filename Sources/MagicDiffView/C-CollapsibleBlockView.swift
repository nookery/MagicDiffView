import SwiftUI

/// 折叠块视图
/// 用于显示可折叠的连续未变动行
struct CollapsibleBlockView: View {
    @State private var block: CollapsibleBlock
    let showLineNumbers: Bool
    let showCheckboxes: Bool
    let font: Font
    let displayMode: ViewMode
    let codeLanguage: CodeLanguage
    let verbose: Bool
    let theme: any DiffTheme
    
    init(
        block: CollapsibleBlock,
        showLineNumbers: Bool,
        showCheckboxes: Bool = false,
        font: Font,
        displayMode: ViewMode = .diff,
        codeLanguage: CodeLanguage,
        verbose: Bool,
        theme: any DiffTheme = DiffThemes.light
    ) {
        self._block = State(initialValue: block)
        self.showLineNumbers = showLineNumbers
        self.showCheckboxes = showCheckboxes
        self.font = font
        self.displayMode = displayMode
        self.codeLanguage = codeLanguage
        self.verbose = verbose
        self.theme = theme
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if block.isCollapsed {
                collapsedView
            } else {
                expandedView
            }
        }
    }
    
    /// 折叠状态的视图
    private var collapsedView: some View {
        Button(action: toggleCollapse) {
            HStack(spacing: 0) {
                // 复选框占位（可选）
                if showCheckboxes {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 28, height: 20)
                }
                
                // 彩色指示条占位
                Rectangle()
                    .fill(.clear)
                    .frame(width: 3)
                
                collapsedLineNumberView
                
                collapsedContentView
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(theme.highlightBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(theme.separatorColor),
            alignment: .bottom
        )
    }
    
    /// 展开状态的视图
    private var expandedView: some View {
        VStack(spacing: 0) {
            // 折叠按钮（与行布局对齐）
            HStack(spacing: 0) {
                // 复选框占位（可选）
                if showCheckboxes {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 28, height: 20)
                }
                
                // 彩色指示条占位
                Rectangle()
                    .fill(.clear)
                    .frame(width: 3)
                
                Button(action: toggleCollapse) {
                    HStack(alignment: .center, spacing: 0) {
                        if showLineNumbers {
                            expandButtonLineNumberView
                        }
                        
                        expandButtonContentView
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .background(theme.highlightBackground)
            }
            
            // 展开的行（与 DiffContentView 布局一致）
            ForEach(Array(block.lines.enumerated()), id: \.offset) { index, line in
                HStack(spacing: 0) {
                    // 复选框占位（可选）
                    if showCheckboxes {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 28, height: 20)
                    }
                    
                    // 彩色指示条（未变动行为透明）
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 3)
                    
                    DiffLineView(
                        line: line,
                        showLineNumbers: showLineNumbers,
                        font: font,
                        codeLanguage: codeLanguage,
                        displayMode: displayMode,
                        verbose: verbose,
                        showIndicator: false,
                        theme: theme
                    )
                }
            }
        }
    }
    
    /// 折叠状态的行号视图
    @ViewBuilder
    private var collapsedLineNumberView: some View {
        HStack(spacing: 0) {
            Text("\(block.startLineNumber)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(theme.lineNumberColor)
                .frame(width: 36, alignment: .trailing)
                .padding(.horizontal, 4)
            
            Rectangle()
                .frame(width: 1)
                .foregroundColor(theme.separatorColor)
            
            Text("\(block.endLineNumber)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(theme.lineNumberColor)
                .frame(width: 36, alignment: .trailing)
                .padding(.horizontal, 4)
        }
        .frame(maxHeight: .infinity)
        .background(theme.gutterBackground.opacity(0.5))
    }
    
    /// 展开按钮的行号视图
    @ViewBuilder
    private var expandButtonLineNumberView: some View {
        HStack(spacing: 0) {
            Image(systemName: "arrow.up.and.down")
                .font(.system(size: 10))
                .foregroundColor(theme.lineNumberColor)
        }
        .frame(width: 89) // 与 DiffLineNumberView 对齐（36+1+36 + padding）
        .frame(maxHeight: .infinity)
        .padding(.vertical, 1)
        .background(theme.gutterBackground)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(theme.separatorColor),
            alignment: .trailing
        )
    }
    
    /// 折叠状态的内容视图
    private var collapsedContentView: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 9))
                .foregroundColor(theme.lineNumberColor.opacity(0.6))
            
            if let contextInfo = block.contextInfo {
                Text(contextInfo)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(theme.lineNumberColor)
            }
            
            Text("(\(block.lines.count) lines)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(theme.lineNumberColor.opacity(0.7))
            
            Spacer()
        }
        .padding(.leading, 8)
        .padding(.vertical, 4)
    }
    
    /// 展开按钮的内容视图
    private var expandButtonContentView: some View {
        HStack(spacing: 0) {
            if let contextInfo = block.contextInfo {
                Text(contextInfo)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(theme.lineNumberColor)
                    .padding(.leading, 8)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .background(theme.highlightBackground)
    }
    
    private func toggleCollapse() {
        withAnimation(.easeInOut(duration: 0.2)) {
            block = CollapsibleBlock(
                lines: block.lines,
                isCollapsed: !block.isCollapsed,
                startLineNumber: block.startLineNumber,
                endLineNumber: block.endLineNumber,
                contextInfo: block.contextInfo
            )
        }
    }
}
