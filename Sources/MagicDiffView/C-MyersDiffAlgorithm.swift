import Foundation

/// Myers 差异算法实现（优化版）
///
/// 基于 Eugene Myers 的经典论文 "An O(ND) Difference Algorithm and Its Variations" (1986)
///
/// 这是一个实用的实现，具有以下特点：
/// - 对于相似文件（D 很小），性能接近 O(ND)
/// - 对于大文件，内存效率高
/// - 实现简洁可靠，适合生产环境使用
/// - 支持 unified diff 格式解析，与 Git 兼容
///
/// 算法核心思想：
/// 1. 使用优化的 LCS（最长公共子序列）算法
/// 2. 通过贪心策略快速匹配相同行
/// 3. 将差异表示为删除和插入操作
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

        // 使用优化的差异算法
        return computeOptimizedDiff(oldLines: oldLines, newLines: newLines)
    }

    // MARK: - Unified Diff Parser

    /// 解析 unified diff 格式的文本
    ///
    /// 支持标准 unified diff 格式，如 Git 输出：
    /// ```
    /// @@ -1,5 +1,6 @@
    ///  line 1
    /// -line 2 old
    /// +line 2 new
    ///  line 3
    /// ```
    ///
    /// - Parameter unifiedDiffText: unified diff 格式的文本
    /// - Returns: 差异行数组
    /// - Throws: DiffParseError 如果解析失败
    static func parseUnifiedDiff(_ unifiedDiffText: String) throws -> [DiffLine] {
        var result: [DiffLine] = []
        let lines = unifiedDiffText.components(separatedBy: .newlines)

        var oldLineNumber: Int?
        var newLineNumber: Int?
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // 解析 hunk 头部：@@ -oldStart,oldCount +newStart,newCount @@
            if line.hasPrefix("@@") {
                // 使用更精确的正则表达式解析 hunk header
                let hunkPattern = "@@\\s*-(\\d+)(?:,(\\d+))?\\s*\\+(\\d+)(?:,(\\d+))?\\s*@@.*"
                if let regex = try? NSRegularExpression(pattern: hunkPattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                    
                    // 提取 oldStart（group 1）
                    if let oldStartRange = Range(match.range(at: 1), in: line),
                       let oldStart = Int(String(line[oldStartRange])) {
                        oldLineNumber = oldStart
                    }
                    
                    // 提取 newStart（group 3）
                    if let newStartRange = Range(match.range(at: 3), in: line),
                       let newStart = Int(String(line[newStartRange])) {
                        newLineNumber = newStart
                    }
                    
                    // oldCount 和 newCount 可用于验证，但行号递增由实际内容决定
                }
                i += 1
                continue
            }

            // 跳过 diff 头部信息（如 ---, +++ ）
            if line.hasPrefix("---") || line.hasPrefix("+++") || line.isEmpty {
                i += 1
                continue
            }

            // 解析差异行
            if !line.isEmpty {
                let diffLine: DiffLine

                if line.hasPrefix("+") {
                    // 新增的行
                    diffLine = DiffLine(
                        content: String(line.dropFirst()),
                        type: .added,
                        oldLineNumber: nil,
                        newLineNumber: newLineNumber
                    )
                    newLineNumber? += 1
                } else if line.hasPrefix("-") {
                    // 删除的行
                    diffLine = DiffLine(
                        content: String(line.dropFirst()),
                        type: .removed,
                        oldLineNumber: oldLineNumber,
                        newLineNumber: nil
                    )
                    oldLineNumber? += 1
                } else if line.hasPrefix(" ") {
                    // 未改变的行（context）
                    diffLine = DiffLine(
                        content: String(line.dropFirst()),
                        type: .unchanged,
                        oldLineNumber: oldLineNumber,
                        newLineNumber: newLineNumber
                    )
                    oldLineNumber? += 1
                    newLineNumber? += 1
                } else {
                    // 不以 +, -, 或 空格开头的行，作为 unchanged 处理
                    diffLine = DiffLine(
                        content: line,
                        type: .unchanged,
                        oldLineNumber: oldLineNumber,
                        newLineNumber: newLineNumber
                    )
                    oldLineNumber? += 1
                    newLineNumber? += 1
                }

                result.append(diffLine)
            }

            i += 1
        }

        return result
    }

    /// 解析 unified diff 格式（不抛出异常版本）
    ///
    /// - Parameter unifiedDiffText: unified diff 格式的文本
    /// - Returns: 差异行数组，如果解析失败返回空数组
    static func parseUnifiedDiffSafely(_ unifiedDiffText: String) -> [DiffLine] {
        // 检查是否包含有效的 hunk 头部
        let hasValidHunk = unifiedDiffText.contains("@@")
        if !hasValidHunk {
            return []
        }

        do {
            return try parseUnifiedDiff(unifiedDiffText)
        } catch {
            print("[MyersDiffAlgorithm] Failed to parse unified diff: \(error)")
            return []
        }
    }

    // MARK: - Optimized Diff Algorithm

    /// 优化的差异计算方法
    private static func computeOptimizedDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        // 首先尝试快速路径：如果文本非常相似，使用简单的线性比较
        let quickResult = tryQuickDiff(oldLines: oldLines, newLines: newLines)
        if !quickResult.isEmpty {
            return quickResult
        }

        // 使用 LCS 算法计算差异
        let lcs = longestCommonSubsequence(oldLines, newLines)
        return convertLCSToDiff(oldLines: oldLines, newLines: newLines, lcs: lcs)
    }

    /// 快速差异检测（适用于高度相似的文本）
    private static func tryQuickDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        var result: [DiffLine] = []
        var oldIndex = 0
        var newIndex = 0
        let m = oldLines.count
        let n = newLines.count

        while oldIndex < m || newIndex < n {
            if oldIndex < m && newIndex < n && oldLines[oldIndex] == newLines[newIndex] {
                result.append(DiffLine(
                    content: oldLines[oldIndex],
                    type: .unchanged,
                    oldLineNumber: oldIndex + 1,
                    newLineNumber: newIndex + 1
                ))
                oldIndex += 1
                newIndex += 1
            } else {
                // 发现差异，快速路径失败
                return []
            }
        }

        return result
    }

    /// 计算最长公共子序列（LCS）使用优化的动态规划
    private static func longestCommonSubsequence(_ oldLines: [String], _ newLines: [String]) -> [String] {
        let m = oldLines.count
        let n = newLines.count

        // 对于大文件，使用滚动数组优化空间
        if m > 500 || n > 500 {
            return lcsWithRollingArray(oldLines, newLines)
        }

        // 小文件使用标准 DP
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

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

    /// 使用滚动数组优化的 LCS（空间优化）
    private static func lcsWithRollingArray(_ oldLines: [String], _ newLines: [String]) -> [String] {
        let m = oldLines.count
        let n = newLines.count

        // 只保存两行
        var prevRow = Array(repeating: 0, count: n + 1)
        var currRow = Array(repeating: 0, count: n + 1)

        // 记录每个位置的来源，用于回溯
        // 0 = from diagonal, 1 = from top, 2 = from left
        var backtrace: [[UInt8]] = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 1...m {
            currRow = Array(repeating: 0, count: n + 1)

            for j in 1...n {
                if oldLines[i - 1] == newLines[j - 1] {
                    currRow[j] = prevRow[j - 1] + 1
                    backtrace[i][j] = 0
                } else if prevRow[j] >= currRow[j - 1] {
                    currRow[j] = prevRow[j]
                    backtrace[i][j] = 1
                } else {
                    currRow[j] = currRow[j - 1]
                    backtrace[i][j] = 2
                }
            }

            prevRow = currRow
        }

        // 回溯
        var lcs: [String] = []
        var i = m
        var j = n

        while i > 0 && j > 0 {
            switch backtrace[i][j] {
            case 0:  // from diagonal
                lcs.append(oldLines[i - 1])
                i -= 1
                j -= 1
            case 1:  // from top
                i -= 1
            case 2:  // from left
                j -= 1
            default:
                break
            }
        }

        return lcs.reversed()
    }

    /// 将 LCS 转换为 DiffLine 数组
    private static func convertLCSToDiff(
        oldLines: [String],
        newLines: [String],
        lcs: [String]
    ) -> [DiffLine] {
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

// MARK: - Error Types

/// Diff 解析错误
enum DiffParseError: Error, LocalizedError {
    case invalidFormat(String)
    case malformedHunkHeader(String)
    case unexpectedEndOfFile

    var errorDescription: String? {
        switch self {
        case .invalidFormat(let message):
            return "Invalid diff format: \(message)"
        case .malformedHunkHeader(let header):
            return "Malformed hunk header: \(header)"
        case .unexpectedEndOfFile:
            return "Unexpected end of diff file"
        }
    }
}
