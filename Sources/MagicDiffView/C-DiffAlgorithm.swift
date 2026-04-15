import Foundation

/// 差异计算算法
///
/// 使用 Myers 算法（Eugene Myers, 1986）计算文本差异
///
/// 算法特点：
/// - 时间复杂度：O((m+n)×D)，其中 m、n 为行数，D 为编辑距离
/// - 空间复杂度：O(m+n)
/// - 适合大文件处理，性能优异
/// - 业界标准算法（Git、GitHub Desktop、VS Code 均使用）
struct DiffAlgorithm {

    /// 默认每次扩展的行数，与 GitHub Desktop 一致
    static let defaultExpansionStep = 20

    /// 计算两个字符串数组的差异
    /// - Parameters:
    ///   - oldLines: 旧文本的行数组
    ///   - newLines: 新文本的行数组
    /// - Returns: 差异行数组
    static func computeDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        // 使用 Myers 算法
        return MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
    }

    /// 将差异行组织成可折叠的项目，并在变更块前后添加 hunk header
    ///
    /// 参考 GitHub Desktop 的渲染方式：
    /// - 变更块之前显示若干行上下文（context lines）
    /// - 变更块以 hunk header（@@ -x,y +a,b @@）分隔
    /// - 上下文行数较多的间隙以折叠块呈现，支持展开
    ///
    /// - Parameters:
    ///   - diffLines: 原始差异行数组
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    ///   - contextLines: 变更块前后保留的上下文行数，默认为3行（与 Git 一致）
    /// - Returns: 包含 hunk header、折叠块的差异项目数组
    static func organizeDiffItems(
        from diffLines: [DiffLine],
        minUnchangedLines: Int = 3,
        contextLines: Int = 3
    ) -> [DiffItem] {
        var result: [DiffItem] = []

        // 第一步：将行按变更分组
        // 每个 group 包含：前导上下文 + 变更行 + 尾随上下文
        let groups = groupDiffLines(diffLines, contextLines: contextLines)

        for (index, group) in groups.enumerated() {
            // 添加 hunk header
            result.append(.hunkHeader(group.header))

            // 添加前导上下文行
            for line in group.leadingContext {
                result.append(.line(line))
            }

            // 添加变更行（添加字符级高亮）
            let (deleted, added) = separateAddedAndDeleted(group.changedLines)
            let (deletedHighlighted, addedHighlighted) = InlineDiff.computeCharHighlightRanges(
                deletedLines: deleted,
                addedLines: added
            )

            // 交替输出 deleted 和 added（保持原始顺序）
            var delIdx = 0
            var addIdx = 0
            for line in group.changedLines {
                if line.type == .removed {
                    if delIdx < deletedHighlighted.count {
                        result.append(.line(deletedHighlighted[delIdx]))
                        delIdx += 1
                    } else {
                        result.append(.line(line))
                    }
                } else if line.type == .added {
                    if addIdx < addedHighlighted.count {
                        result.append(.line(addedHighlighted[addIdx]))
                        addIdx += 1
                    } else {
                        result.append(.line(line))
                    }
                } else {
                    result.append(.line(line))
                }
            }

            // 添加尾随上下文行
            for line in group.trailingContext {
                result.append(.line(line))
            }

            // 在非末尾的 group 之间添加折叠块（如果存在多余上下文行）
            if index < groups.count - 1 {
                let nextGroup = groups[index + 1]
                let gapLines = nextGroup.extraContextBefore

                if gapLines.count > 0 {
                    let expansionType = getExpansionType(
                        gapLineCount: gapLines.count,
                        isFirstGroup: false,
                        isLastGroup: false
                    )
                    let startLine = gapLines.first?.oldLineNumber ?? 1
                    let endLine = gapLines.last?.oldLineNumber ?? startLine

                    let block = CollapsibleBlock(
                        lines: gapLines,
                        isCollapsed: true,
                        startLineNumber: startLine,
                        endLineNumber: endLine,
                        contextInfo: "@@ -\(startLine),\(gapLines.count) +\(startLine),\(gapLines.count) @@",
                        expansionType: expansionType,
                        hiddenLineCount: 0
                    )
                    result.append(.collapsibleBlock(block))
                }
            }
        }

        return result
    }

    /// 将差异行分组为变更块
    private static func groupDiffLines(
        _ diffLines: [DiffLine],
        contextLines: Int
    ) -> [DiffGroup] {
        var groups: [DiffGroup] = []
        var i = 0

        while i < diffLines.count {
            // 找到下一个变更行
            var changeStart = i
            while changeStart < diffLines.count && diffLines[changeStart].type == .unchanged {
                changeStart += 1
            }

            if changeStart >= diffLines.count { break }

            // 收集变更行
            var changeEnd = changeStart
            while changeEnd < diffLines.count && diffLines[changeEnd].type != .unchanged {
                changeEnd += 1
            }

            // 收集变更行
            let changedLines = Array(diffLines[changeStart..<changeEnd])

            // 收集尾随上下文行
            var trailingEnd = changeEnd
            while trailingEnd < diffLines.count && diffLines[trailingEnd].type == .unchanged && (trailingEnd - changeEnd) < contextLines {
                trailingEnd += 1
            }
            let trailingContext = Array(diffLines[changeEnd..<trailingEnd])

            // 收集前导上下文行
            let leadingStart = max(0, changeStart - contextLines)
            let leadingContext = Array(diffLines[leadingStart..<changeStart])

            // 计算 hunk header 的行号范围
            // 参考 Git 的 unified diff 格式：
            // oldCount = 未变动行数 + 删除行数（旧文件中的行总数）
            // newCount = 未变动行数 + 新增行数（新文件中的行总数）
            let oldCount = leadingContext.count + changedLines.filter { $0.type != .added }.count + trailingContext.count
            let newCount = leadingContext.count + changedLines.filter { $0.type != .removed }.count + trailingContext.count
            let allLines = leadingContext + changedLines + trailingContext

            // 多余的上下文行（前导之前的行）
            let extraContextBefore: [DiffLine] = leadingStart > 0
                ? Array(diffLines[max(0, changeStart - contextLines * 3)...leadingStart].filter { $0.type == .unchanged })
                : []

            // 检查前面是否有未被消费的上下文行
            let fullLeadingStart: Int
            if groups.isEmpty {
                // 第一个 group，前导上下文之前的行也属于它
                fullLeadingStart = max(0, changeStart - contextLines)
            } else {
                fullLeadingStart = leadingStart
            }

            let actualLeadingContext = fullLeadingStart < leadingStart
                ? Array(diffLines[fullLeadingStart..<leadingStart])
                : []

            let header = HunkHeader(
                oldStartLine: allLines.first?.oldLineNumber ?? 1,
                oldLineCount: oldCount,
                newStartLine: allLines.first?.newLineNumber ?? 1,
                newLineCount: newCount
            )

            groups.append(DiffGroup(
                header: header,
                leadingContext: actualLeadingContext + leadingContext,
                changedLines: changedLines,
                trailingContext: trailingContext,
                extraContextBefore: groups.isEmpty && fullLeadingStart > 0
                    ? Array(diffLines[0..<fullLeadingStart])
                    : []
            ))

            i = trailingEnd
        }

        return groups
    }

    /// 根据 gap 行数判断扩展类型
    /// 参考 GitHub Desktop 的 `getHunkHeaderExpansionType()`
    private static func getExpansionType(gapLineCount: Int, isFirstGroup: Bool, isLastGroup: Bool) -> HunkExpansionType {
        if gapLineCount <= defaultExpansionStep {
            return .short
        }
        if isFirstGroup {
            return .up
        }
        if isLastGroup {
            return .down
        }
        return .both
    }

    /// 分离 deleted 和 added 行
    private static func separateAddedAndDeleted(_ lines: [DiffLine]) -> (deleted: [DiffLine], added: [DiffLine]) {
        var deleted = [DiffLine]()
        var added = [DiffLine]()
        for line in lines {
            switch line.type {
            case .removed:
                deleted.append(line)
            case .added:
                added.append(line)
            default:
                break
            }
        }
        return (deleted, added)
    }
}

/// 变更分组
private struct DiffGroup {
    let header: HunkHeader
    let leadingContext: [DiffLine]
    let changedLines: [DiffLine]
    let trailingContext: [DiffLine]
    /// 前导上下文之前的额外行（在折叠块中展示）
    let extraContextBefore: [DiffLine]
}
