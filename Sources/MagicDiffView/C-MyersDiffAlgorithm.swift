import Foundation

/// Myers 差异算法实现
///
/// 基于 Eugene Myers 的经典算法思想，使用动态规划实现最长公共子序列（LCS）
/// "An O(ND) Difference Algorithm and Its Variations" (1986)
///
/// 虽然不是完整的 O(ND) 实现，但基于 Myers 算法的核心思想：
/// - 找出最长公共子序列
/// - 将差异表示为插入和删除操作
struct MyersDiffAlgorithm {

    // MARK: - Public API

    /// 计算两个文本数组的差异
    /// - Parameters:
    ///   - oldLines: 旧文本的行数组
    ///   - newLines: 新文本的行数组
    /// - Returns: 差异行数组
    static func computeDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        // 处理边界情况
        if oldLines.isEmpty && newLines.isEmpty {
            return []
        }

        if oldLines.isEmpty {
            return newLines.enumerated().map { index, line in
                DiffLine(
                    content: line,
                    type: .added,
                    oldLineNumber: nil,
                    newLineNumber: index + 1
                )
            }
        }

        if newLines.isEmpty {
            return oldLines.enumerated().map { index, line in
                DiffLine(
                    content: line,
                    type: .removed,
                    oldLineNumber: index + 1,
                    newLineNumber: nil
                )
            }
        }

        // 使用 LCS 算法计算差异
        let lcs = longestCommonSubsequence(oldLines, newLines)
        return convertLCToDiff(oldLines: oldLines, newLines: newLines, lcs: lcs)
    }

    // MARK: - LCS Algorithm

    /// 计算最长公共子序列（使用动态规划）
    /// 这是 Myers 算法的核心思想：找出两文本的最长公共部分
    private static func longestCommonSubsequence(_ oldLines: [String], _ newLines: [String]) -> [String] {
        let m = oldLines.count
        let n = newLines.count

        // 创建 DP 表
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        // 填充 DP 表
        for i in 1...m {
            for j in 1...n {
                if oldLines[i - 1] == newLines[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // 回溯找出 LCS
        var lcs: [String] = []
        var i = m
        var j = n

        while i > 0 && j > 0 {
            if oldLines[i - 1] == newLines[j - 1] {
                lcs.append(oldLines[i - 1])
                i -= 1
                j -= 1
            } else if dp[i - 1][j] > dp[i][j - 1] {
                i -= 1
            } else {
                j -= 1
            }
        }

        return lcs.reversed()
    }

    /// 将 LCS 转换为 DiffLine 数组
    /// 按照 Myers 算法的思想，将差异表示为删除和插入操作
    private static func convertLCToDiff(oldLines: [String], newLines: [String], lcs: [String]) -> [DiffLine] {
        var result: [DiffLine] = []
        var oldIndex = 0
        var newIndex = 0
        var lcsIndex = 0

        while oldIndex < oldLines.count || newIndex < newLines.count {
            // 检查是否有匹配的 LCS 元素
            if lcsIndex < lcs.count &&
               oldIndex < oldLines.count &&
               newIndex < newLines.count &&
               oldLines[oldIndex] == lcs[lcsIndex] &&
               newLines[newIndex] == lcs[lcsIndex] {
                // 相同的行
                result.append(DiffLine(
                    content: oldLines[oldIndex],
                    type: .unchanged,
                    oldLineNumber: oldIndex + 1,
                    newLineNumber: newIndex + 1,
                    highlightRanges: nil
                ))
                oldIndex += 1
                newIndex += 1
                lcsIndex += 1
            } else if oldIndex < oldLines.count &&
                      (lcsIndex >= lcs.count || oldLines[oldIndex] != lcs[lcsIndex]) {
                // 删除的行（先处理删除）
                result.append(DiffLine(
                    content: oldLines[oldIndex],
                    type: .removed,
                    oldLineNumber: oldIndex + 1,
                    newLineNumber: nil,
                    highlightRanges: nil
                ))
                oldIndex += 1
            } else if newIndex < newLines.count {
                // 新增的行
                result.append(DiffLine(
                    content: newLines[newIndex],
                    type: .added,
                    oldLineNumber: nil,
                    newLineNumber: newIndex + 1,
                    highlightRanges: nil
                ))
                newIndex += 1
            }
        }

        return result
    }
}
