import Foundation

/// 差异计算算法
/// 核心改进：采用"区间合并"策略，与 GitHub Desktop 和 Git 的行为完全一致。
struct DiffAlgorithm {

    static let defaultExpansionStep = 20

    static func computeDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        return MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
    }

    static func organizeDiffItems(
        from diffLines: [DiffLine],
        minUnchangedLines: Int = 3,
        contextLines: Int = 3
    ) -> [DiffItem] {
        var result: [DiffItem] = []
        
        // 1. 使用新的分组算法
        let groups = groupDiffLines(diffLines, contextLines: contextLines)

        for (index, group) in groups.enumerated() {
            // 计算 hunk 的扩展类型（参考 GitHub Desktop）
            let expansionType = computeExpansionType(
                for: group,
                at: index,
                totalGroups: groups.count,
                allDiffLines: diffLines,
                groups: groups
            )
            
            result.append(.hunkHeader(group.header, expansionType: expansionType))

            // 前导上下文
            for line in group.leadingContext {
                result.append(.line(line))
            }

            // 变更行（添加字符级高亮）
            let (deleted, added) = separateAddedAndDeleted(group.changedLines)
            let (deletedHighlighted, addedHighlighted) = InlineDiff.computeCharHighlightRanges(
                deletedLines: deleted,
                addedLines: added
            )

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
                    // 内部未变动行（合并后的变更块中间的上下文）
                    result.append(.line(line))
                }
            }

            // 尾随上下文
            for line in group.trailingContext {
                result.append(.line(line))
            }

            // 折叠块（hunk 之间的空白区域）
            if index < groups.count - 1 {
                let gapLines = group.extraContextBefore
                if !gapLines.isEmpty {
                    let startLine = gapLines.first?.oldLineNumber ?? 1
                    let endLine = gapLines.last?.oldLineNumber ?? startLine
                    let gap = endLine - startLine + 1
                    let block = CollapsibleBlock(
                        lines: gapLines,
                        isCollapsed: true,
                        startLineNumber: startLine,
                        endLineNumber: endLine,
                        contextInfo: "@@ -\(startLine),\(gapLines.count) +\(startLine),\(gapLines.count) @@",
                        expansionType: gap <= defaultExpansionStep ? .short : .both,
                        hiddenLineCount: gapLines.count
                    )
                    result.append(.collapsibleBlock(block))
                }
            }
        }
        return result
    }

    /// 计算 Hunk 的扩展类型（参考 GitHub Desktop 的逻辑）
    private static func computeExpansionType(
        for group: DiffGroup,
        at index: Int,
        totalGroups: Int,
        allDiffLines: [DiffLine],
        groups: [DiffGroup]
    ) -> HunkExpansionType {
        // 只有一个 hunk，无法扩展
        if totalGroups == 1 {
            return .none
        }

        // 计算该 hunk 上方和下方的空白行数
        let hasGapAbove = index > 0 && !groups[index - 1].extraContextBefore.isEmpty
        let hasGapBelow = index < totalGroups - 1 && !group.extraContextBefore.isEmpty

        // 第一个 hunk
        if index == 0 {
            return hasGapBelow ? .down : .none
        }

        // 最后一个 hunk
        if index == totalGroups - 1 {
            return hasGapAbove ? .up : .none
        }

        // 中间的 hunk
        if hasGapAbove && hasGapBelow {
            return .both
        } else if hasGapAbove {
            return .up
        } else if hasGapBelow {
            return .down
        }

        return .none
    }

    /// 核心修复：区间合并分组算法
    /// 逻辑：
    /// 1. 找到所有变更簇。
    /// 2. 向两侧扩展上下文。
    /// 3. 合并重叠或相邻的区间（解决分块过细和重复显示问题）。
    private static func groupDiffLines(_ diffLines: [DiffLine], contextLines: Int) -> [DiffGroup] {
        if diffLines.isEmpty { return [] }

        // 1. 找到变更簇的索引范围
        var clusters: [(start: Int, end: Int)] = []
        var i = 0
        while i < diffLines.count {
            if diffLines[i].type != .unchanged {
                let start = i
                while i < diffLines.count && diffLines[i].type != .unchanged {
                    i += 1
                }
                clusters.append((start: start, end: i))
            } else {
                i += 1
            }
        }
        if clusters.isEmpty { return [] }

        // 2. 扩展并合并区间
        var mergedRanges: [(start: Int, end: Int)] = []

        for cluster in clusters {
            let expStart = max(0, cluster.start - contextLines)
            let expEnd = min(diffLines.count, cluster.end + contextLines)

            if var last = mergedRanges.popLast() {
                // 如果重叠或相邻，则合并
                if expStart <= last.end {
                    last.end = max(last.end, expEnd)
                    mergedRanges.append(last)
                } else {
                    mergedRanges.append(last)
                    mergedRanges.append((expStart, expEnd))
                }
            } else {
                mergedRanges.append((expStart, expEnd))
            }
        }

        // 3. 构建 DiffGroup
        var groups: [DiffGroup] = []

        for (idx, range) in mergedRanges.enumerated() {
            let lines = Array(diffLines[range.start..<range.end])

            var leadingContext: [DiffLine] = []
            var changedLines: [DiffLine] = []
            var trailingContext: [DiffLine] = []

            if let firstChangeIdx = lines.firstIndex(where: { $0.type != .unchanged }) {
                leadingContext = Array(lines[..<firstChangeIdx])
                if let lastChangeIdx = lines.lastIndex(where: { $0.type != .unchanged }) {
                    changedLines = Array(lines[firstChangeIdx...lastChangeIdx])
                    trailingContext = Array(lines[(lastChangeIdx + 1)...])
                }
            }

            // 计算 Hunk Header 行号
            let firstLine = lines.first!
            let oldStart = firstLine.oldLineNumber ?? 1
            // 修复：如果首行是删除行，回退到 oldLineNumber，避免出现错误的 `+1` 行号
            let newStart = firstLine.newLineNumber ?? firstLine.oldLineNumber ?? 1

            var oldCount = 0, newCount = 0
            for line in lines {
                switch line.type {
                case .unchanged: oldCount += 1; newCount += 1
                case .removed: oldCount += 1
                case .added: newCount += 1
                case .modified: oldCount += 1; newCount += 1
                }
            }

            let header = HunkHeader(
                oldStartLine: oldStart,
                oldLineCount: oldCount,
                newStartLine: newStart,
                newLineCount: newCount
            )

            var extraContextBefore: [DiffLine] = []
            if idx > 0 {
                let prevRange = mergedRanges[idx - 1]
                if range.start > prevRange.end {
                    extraContextBefore = Array(diffLines[prevRange.end..<range.start])
                }
            }

            groups.append(DiffGroup(
                header: header,
                leadingContext: leadingContext,
                changedLines: changedLines,
                trailingContext: trailingContext,
                extraContextBefore: extraContextBefore
            ))
        }
        return groups
    }

    private static func separateAddedAndDeleted(_ lines: [DiffLine]) -> (deleted: [DiffLine], added: [DiffLine]) {
        var del = [DiffLine](), add = [DiffLine]()
        for line in lines {
            if line.type == .removed { del.append(line) }
            else if line.type == .added { add.append(line) }
        }
        return (del, add)
    }
}

private struct DiffGroup {
    let header: HunkHeader
    let leadingContext: [DiffLine]
    let changedLines: [DiffLine]
    let trailingContext: [DiffLine]
    let extraContextBefore: [DiffLine]
}
