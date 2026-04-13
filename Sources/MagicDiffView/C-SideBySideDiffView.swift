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

    @ViewBuilder
    private func sideBySideLineView(item: SideBySideItem, side: Side) -> some View {
        let content = content(for: item, side: side)
        let lineNumber = lineNumber(for: item, side: side)
        let lineType = lineType(for: item, side: side)

        // Hunk Header 行特殊渲染
        if item.isHunkHeader {
            HStack(spacing: 0) {
                Text(content)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(theme.lineNumberColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 20)
            .background(theme.highlightBackground)
        } else {
            let backgroundColor: Color = backgroundColor(for: lineType)
            let textColor: Color = textColor(for: lineType)

            HStack(spacing: 0) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 20)
            .background(backgroundColor)
        }
    }

    // MARK: - Helper Methods for ViewBuilder

    private func content(for item: SideBySideItem, side: Side) -> String {
        switch side {
        case .old: return item.oldContent
        case .new: return item.newContent
        }
    }

    private func lineNumber(for item: SideBySideItem, side: Side) -> String? {
        switch side {
        case .old: return item.oldLineNumber
        case .new: return item.newLineNumber
        }
    }

    private func lineType(for item: SideBySideItem, side: Side) -> DiffType {
        switch side {
        case .old: return item.oldType
        case .new: return item.newType
        }
    }

    // MARK: - Helper

    private func backgroundColor(for type: DiffType) -> Color {
        switch type {
        case .unchanged: return theme.unchangedBackground
        case .added: return theme.addedBackground
        case .removed: return theme.removedBackground
        case .modified: return theme.modifiedBackground
        }
    }

    private func textColor(for type: DiffType) -> Color {
        switch type {
        case .unchanged: return theme.unchangedTextColor
        case .added: return theme.addedTextColor
        case .removed: return theme.removedTextColor
        case .modified: return theme.modifiedTextColor
        }
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
                    oldItems.append(SideBySideItem(
                        oldContent: line.content,
                        oldLineNumber: line.oldLineNumber.map { "\($0)" },
                        oldType: .removed,
                        newContent: "",
                        newLineNumber: nil,
                        newType: .removed
                    ))
                    newItems.append(SideBySideItem(
                        oldContent: "",
                        oldLineNumber: nil,
                        oldType: .removed,
                        newContent: "",
                        newLineNumber: nil,
                        newType: .removed
                    ))
                } else if line.type == .added {
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
            case let .hunkHeader(header):
                let placeholder = header.toDiffLineRepresentation()
                oldItems.append(SideBySideItem(
                    oldContent: placeholder,
                    oldLineNumber: nil,
                    oldType: .unchanged,
                    newContent: placeholder,
                    newLineNumber: nil,
                    newType: .unchanged,
                    isHunkHeader: true
                ))
                newItems.append(SideBySideItem(
                    oldContent: placeholder,
                    oldLineNumber: nil,
                    oldType: .unchanged,
                    newContent: placeholder,
                    newLineNumber: nil,
                    newType: .unchanged,
                    isHunkHeader: true
                ))
            case let .collapsibleBlock(block):
                if block.isCollapsed {
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
        let isHunkHeader: Bool

        init(oldContent: String, oldLineNumber: String?, oldType: DiffType, newContent: String, newLineNumber: String?, newType: DiffType, isHunkHeader: Bool = false) {
            self.oldContent = oldContent
            self.oldLineNumber = oldLineNumber
            self.oldType = oldType
            self.newContent = newContent
            self.newLineNumber = newLineNumber
            self.newType = newType
            self.isHunkHeader = isHunkHeader
        }
    }
}
