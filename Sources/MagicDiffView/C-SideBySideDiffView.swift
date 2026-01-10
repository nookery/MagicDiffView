import SwiftUI

/// 并排差异视图
///
/// 将旧版本和新版本并排显示，类似于 GitHub Desktop 的 side-by-side diff 模式
struct SideBySideDiffView: View {
    let diffItems: [DiffItem]
    let showLineNumbers: Bool
    let font: Font
    let selectedLanguage: CodeLanguage
    let theme: any DiffTheme
    let verbose: Bool

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧：旧版本
                leftSideView
                    .frame(maxWidth: geometry.size.width / 2)

                Divider()

                // 右侧：新版本
                rightSideView
                    .frame(maxWidth: geometry.size.width / 2)
            }
        }
    }

    // MARK: - Left Side View

    private var leftSideView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(preparedItems.old.enumerated()), id: \.offset) { _, item in
                    sideBySideLineView(item: item, side: .old)
                }
            }
        }
        .background(theme.backgroundColor)
    }

    // MARK: - Right Side View

    private var rightSideView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(preparedItems.new.enumerated()), id: \.offset) { _, item in
                    sideBySideLineView(item: item, side: .new)
                }
            }
        }
        .background(theme.backgroundColor)
    }

    // MARK: - Line View

    private func sideBySideLineView(item: SideBySideItem, side: Side) -> some View {
        let content: String
        let lineNumber: String?
        let lineType: DiffType

        switch side {
        case .old:
            content = item.oldContent
            lineNumber = item.oldLineNumber
            lineType = item.oldType
        case .new:
            content = item.newContent
            lineNumber = item.newLineNumber
            lineType = item.newType
        }

        // 背景色
        let backgroundColor: Color = {
            switch lineType {
            case .unchanged:
                return theme.unchangedBackground
            case .added:
                return theme.addedBackground
            case .removed:
                return theme.removedBackground
            case .modified:
                return theme.modifiedBackground
            }
        }()

        // 文字色
        let textColor: Color = {
            switch lineType {
            case .unchanged:
                return theme.unchangedTextColor
            case .added:
                return theme.addedTextColor
            case .removed:
                return theme.removedTextColor
            case .modified:
                return theme.modifiedTextColor
            }
        }()

        return HStack(spacing: 0) {
            // 行号
            if showLineNumbers {
                Text(lineNumber ?? "")
                    .font(font)
                    .foregroundColor(theme.lineNumberColor)
                    .frame(width: 44, alignment: .trailing)
                    .padding(.trailing, 8)
                    .background(theme.gutterBackground.opacity(0.5))
            }

            // 内容
            Text(content)
                .font(font)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
        }
        .frame(minHeight: 20)
        .background(backgroundColor)
    }

    // MARK: - Data Preparation

    private var preparedItems: (old: [SideBySideItem], new: [SideBySideItem]) {
        var oldItems: [SideBySideItem] = []
        var newItems: [SideBySideItem] = []
        var oldIndex = 0
        var newIndex = 0

        for item in diffItems {
            switch item {
            case let .line(line):
                if line.type == .unchanged {
                    // 相同行：两边都显示
                    oldItems.append(SideBySideItem(
                        oldContent: line.content,
                        oldLineNumber: line.oldLineNumber.map { "\($0)" },
                        oldType: .unchanged,
                        newContent: line.content,
                        newLineNumber: line.newLineNumber.map { "\($0)" },
                        newType: .unchanged
                    ))
                    newItems.append(SideBySideItem(
                        oldContent: line.content,
                        oldLineNumber: line.oldLineNumber.map { "\($0)" },
                        oldType: .unchanged,
                        newContent: line.content,
                        newLineNumber: line.newLineNumber.map { "\($0)" },
                        newType: .unchanged
                    ))
                } else if line.type == .removed {
                    // 删除行：只在左侧显示
                    oldItems.append(SideBySideItem(
                        oldContent: line.content,
                        oldLineNumber: line.oldLineNumber.map { "\($0)" },
                        oldType: .removed,
                        newContent: "",
                        newLineNumber: nil,
                        newType: .removed
                    ))
                    // 右侧添加占位符
                    newItems.append(SideBySideItem(
                        oldContent: "",
                        oldLineNumber: nil,
                        oldType: .removed,
                        newContent: "",
                        newLineNumber: nil,
                        newType: .removed
                    ))
                } else if line.type == .added {
                    // 添加行：只在右侧显示
                    // 左侧添加占位符
                    oldItems.append(SideBySideItem(
                        oldContent: "",
                        oldLineNumber: nil,
                        oldType: .added,
                        newContent: "",
                        newLineNumber: nil,
                        newType: .added
                    ))
                    newItems.append(SideBySideItem(
                        oldContent: "",
                        oldLineNumber: nil,
                        oldType: .added,
                        newContent: line.content,
                        newLineNumber: line.newLineNumber.map { "\($0)" },
                        newType: .added
                    ))
                }
            case let .collapsibleBlock(block):
                if block.isCollapsed {
                    // 折叠块：显示占位符
                    let placeholder = "--- \(block.lines.count) lines collapsed ---"

                    oldItems.append(SideBySideItem(
                        oldContent: placeholder,
                        oldLineNumber: "\(block.startLineNumber)",
                        oldType: .unchanged,
                        newContent: placeholder,
                        newLineNumber: "\(block.startLineNumber)",
                        newType: .unchanged
                    ))
                    newItems.append(SideBySideItem(
                        oldContent: placeholder,
                        oldLineNumber: "\(block.startLineNumber)",
                        oldType: .unchanged,
                        newContent: placeholder,
                        newLineNumber: "\(block.startLineNumber)",
                        newType: .unchanged
                    ))
                } else {
                    // 展开的折叠块：逐行处理
                    for line in block.lines {
                        oldItems.append(SideBySideItem(
                            oldContent: line.content,
                            oldLineNumber: line.oldLineNumber.map { "\($0)" },
                            oldType: line.type,
                            newContent: line.content,
                            newLineNumber: line.newLineNumber.map { "\($0)" },
                            newType: line.type
                        ))
                        newItems.append(SideBySideItem(
                            oldContent: line.content,
                            oldLineNumber: line.oldLineNumber.map { "\($0)" },
                            oldType: line.type,
                            newContent: line.content,
                            newLineNumber: line.newLineNumber.map { "\($0)" },
                            newType: line.type
                        ))
                    }
                }
            }

            oldIndex += 1
            newIndex += 1
        }

        return (oldItems, newItems)
    }

    // MARK: - Data Types

    private enum Side {
        case old
        case new
    }

    private struct SideBySideItem {
        let oldContent: String
        let oldLineNumber: String?
        let oldType: DiffType
        let newContent: String
        let newLineNumber: String?
        let newType: DiffType
    }
}
