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

    /// 计算两个字符串数组的差异
    /// - Parameters:
    ///   - oldLines: 旧文本的行数组
    ///   - newLines: 新文本的行数组
    /// - Returns: 差异行数组
    static func computeDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        // 使用 Myers 算法
        return MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
    }

    /// 将差异行组织成可折叠的项目
    /// - Parameters:
    ///   - diffLines: 原始差异行数组
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    /// - Returns: 包含折叠块的差异项目数组
    static func organizeDiffItems(from diffLines: [DiffLine], minUnchangedLines: Int = 3) -> [DiffItem] {
        var result: [DiffItem] = []
        var currentUnchangedLines: [DiffLine] = []

        for line in diffLines {
            if line.type == .unchanged {
                currentUnchangedLines.append(line)
            } else {
                // 遇到变动行，处理之前累积的未变动行
                if !currentUnchangedLines.isEmpty {
                    if currentUnchangedLines.count >= minUnchangedLines {
                        // 创建折叠块
                        let startLine = currentUnchangedLines.first?.oldLineNumber ?? 1
                        let endLine = currentUnchangedLines.last?.oldLineNumber ?? 1
                        let block = CollapsibleBlock(
                            lines: currentUnchangedLines,
                            isCollapsed: true,
                            startLineNumber: startLine,
                            endLineNumber: endLine,
                            contextInfo: "@@ -\(startLine),\(currentUnchangedLines.count) +\(startLine),\(currentUnchangedLines.count) @@"
                        )
                        result.append(.collapsibleBlock(block))
                    } else {
                        // 行数不够，直接添加为普通行
                        for unchangedLine in currentUnchangedLines {
                            result.append(.line(unchangedLine))
                        }
                    }
                    currentUnchangedLines.removeAll()
                }

                // 添加当前变动行
                result.append(.line(line))
            }
        }

        // 处理最后剩余的未变动行
        if !currentUnchangedLines.isEmpty {
            if currentUnchangedLines.count >= minUnchangedLines {
                let startLine = currentUnchangedLines.first?.oldLineNumber ?? 1
                let endLine = currentUnchangedLines.last?.oldLineNumber ?? 1
                let block = CollapsibleBlock(
                    lines: currentUnchangedLines,
                    isCollapsed: true,
                    startLineNumber: startLine,
                    endLineNumber: endLine,
                    contextInfo: "@@ -\(startLine),\(currentUnchangedLines.count) +\(startLine),\(currentUnchangedLines.count) @@"
                )
                result.append(.collapsibleBlock(block))
            } else {
                for unchangedLine in currentUnchangedLines {
                    result.append(.line(unchangedLine))
                }
            }
        }

        return result
    }
}
