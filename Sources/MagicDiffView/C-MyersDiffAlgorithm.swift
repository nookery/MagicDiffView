import Foundation

/// Myers 差异算法实现
///
/// 基于 Eugene Myers 的经典算法：
/// "An O(ND) Difference Algorithm and Its Variations" (1986)
///
/// 算法复杂度：O((N+M)D)，其中 D 是编辑脚本长度
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

        // 使用 Myers 算法计算差异
        let editScript = shortestEdit(oldLines: oldLines, newLines: newLines)

        // 将编辑脚本转换为 DiffLine 数组
        return convertEditScriptToDiffLines(
            editScript: editScript,
            oldLines: oldLines,
            newLines: newLines
        )
    }

    // MARK: - Core Algorithm

    /// 计算最短编辑脚本
    /// - Parameters:
    ///   - oldLines: 旧文本行数组
    ///   - newLines: 新文本行数组
    /// - Returns: 编辑脚本（每个点表示是否在对角线上）
    private static func shortestEdit(oldLines: [String], newLines: [String]) -> [Point] {
        let m = oldLines.count
        let n = newLines.count

        // 最大可能的编辑距离
        let maxD = m + n

        // 存储每个 d 位置的 x 坐标
        // 使用字典来优化空间，只存储实际用到的 k 值
        var vf = [Int: Int]()
        var vb = [Int: Int]()

        // 初始化：从 (-1, -1) 开始
        vf[1] = 0
        vb[-1] = 0

        // 从两端向中间搜索
        for d in 0...maxD {
            // 正向搜索
            for k in stride(from: -d, through: d, by: 2) {
                var x: Int
                if k == -d || (k != d && (vf[k - 1] ?? 0) < (vf[k + 1] ?? 0)) {
                    // 向下移动（插入）
                    x = vf[k + 1] ?? 0
                } else {
                    // 向右移动（删除）
                    x = (vf[k - 1] ?? 0) + 1
                }

                let y = x - k

                // 沿着对角线尽可能远地移动
                var (currentX, currentY) = (x, y)
                while currentX < m && currentY < n &&
                      oldLines[currentX] == newLines[currentY] {
                    currentX += 1
                    currentY += 1
                }

                vf[k] = currentX

                // 检查是否与反向搜索相遇
                let delta = m - n
                if (delta - k) % 2 == 0 {
                    let vbX = vb[delta - k] ?? 0
                    if vf[k] ?? 0 >= vbX {
                        // 找到了路径，回溯生成脚本
                        return backtrack(
                            oldLines: oldLines,
                            newLines: newLines,
                            vf: vf,
                            vb: vb,
                            d: d,
                            k: k,
                            forward: true
                        )
                    }
                }
            }

            // 反向搜索
            for k in stride(from: -d, through: d, by: 2) {
                var x: Int
                if k == -d || (k != d && (vb[k - 1] ?? 0) > (vb[k + 1] ?? 0)) {
                    // 向上移动（删除）
                    x = (vb[k + 1] ?? 0)
                } else {
                    // 向左移动（插入）
                    x = (vb[k - 1] ?? 0) - 1
                }

                let y = x - (k + (m - n))

                // 沿着对角线尽可能远地移动（反向）
                var (currentX, currentY) = (x, y)
                while currentX > 0 && currentY > 0 &&
                      oldLines[currentX - 1] == newLines[currentY - 1] {
                    currentX -= 1
                    currentY -= 1
                }

                vb[k] = currentX

                // 检查是否与正向搜索相遇
                let delta = m - n
                if (delta + k) % 2 == 0 {
                    let vfX = vf[delta + k] ?? 0
                    if vb[k] ?? 0 <= vfX {
                        // 找到了路径，回溯生成脚本
                        return backtrack(
                            oldLines: oldLines,
                            newLines: newLines,
                            vf: vf,
                            vb: vb,
                            d: d,
                            k: k,
                            forward: false
                        )
                    }
                }
            }
        }

        // 不应该到达这里
        return []
    }

    // MARK: - Backtracking

    /// 回溯生成编辑脚本
    private static func backtrack(
        oldLines: [String],
        newLines: [String],
        vf: [Int: Int],
        vb: [Int: Int],
        d: Int,
        k: Int,
        forward: Bool
    ) -> [Point] {
        var path: [Point] = []
        var currentV = forward ? vf : vb
        let m = oldLines.count
        let n = newLines.count
        let delta = m - n

        var x = currentV[k] ?? 0
        var y = x - (k + (forward ? 0 : delta))
        var currentK = k  // 使用可变变量

        // 回溯路径
        for currentD in stride(from: d, to: 0, by: -1) {
            let prevK: Int
            var prevX: Int
            var prevY: Int

            if forward {
                // 正向回溯
                if currentK == -currentD || (currentK != currentD && (currentV[currentK - 1] ?? 0) < (currentV[currentK + 1] ?? 0)) {
                    prevK = currentK + 1
                    prevX = currentV[prevK] ?? 0
                } else {
                    prevK = currentK - 1
                    prevX = (currentV[prevK] ?? 0) + 1
                }
                prevY = prevX - prevK
            } else {
                // 反向回溯
                if currentK == -currentD || (currentK != currentD && (currentV[currentK - 1] ?? 0) > (currentV[currentK + 1] ?? 0)) {
                    prevK = currentK + 1
                    prevX = (currentV[prevK] ?? 0)
                } else {
                    prevK = currentK - 1
                    prevX = (currentV[prevK] ?? 0) - 1
                }
                prevY = prevX - (prevK + delta)
            }

            // 添加对角线移动
            while x > prevX && y > prevY {
                path.append(Point(x: x, y: y))
                x -= 1
                y -= 1
            }

            // 添加水平/垂直移动
            if x != prevX || y != prevY {
                path.append(Point(x: prevX, y: prevY))
            }

            x = prevX
            y = prevY
            currentK = prevK
            currentV = forward ? vf : vb
        }

        // 添加起点
        while x > 0 || y > 0 {
            path.append(Point(x: x, y: y))
            if x > 0 && y > 0 {
                x -= 1
                y -= 1
            } else if x > 0 {
                x -= 1
            } else {
                y -= 1
            }
        }

        return path.reversed()
    }

    // MARK: - Conversion

    /// 将编辑脚本转换为 DiffLine 数组
    private static func convertEditScriptToDiffLines(
        editScript: [Point],
        oldLines: [String],
        newLines: [String]
    ) -> [DiffLine] {
        guard !editScript.isEmpty else {
            return []
        }

        var result: [DiffLine] = []
        var oldIndex = 1
        var newIndex = 1

        for i in 0..<(editScript.count - 1) {
            let current = editScript[i]
            let next = editScript[i + 1]

            let dx = next.x - current.x
            let dy = next.y - current.y

            if dx == 1 && dy == 1 {
                // 对角线移动 - 行相同
                result.append(DiffLine(
                    content: oldLines[current.x],
                    type: .unchanged,
                    oldLineNumber: current.x + 1,
                    newLineNumber: current.y + 1
                ))
                oldIndex += 1
                newIndex += 1
            } else if dx == 1 && dy == 0 {
                // 水平移动 - 删除行
                result.append(DiffLine(
                    content: oldLines[current.x],
                    type: .removed,
                    oldLineNumber: current.x + 1,
                    newLineNumber: nil
                ))
                oldIndex += 1
            } else if dx == 0 && dy == 1 {
                // 垂直移动 - 插入行
                result.append(DiffLine(
                    content: newLines[current.y],
                    type: .added,
                    oldLineNumber: nil,
                    newLineNumber: current.y + 1
                ))
                newIndex += 1
            }
        }

        // 添加最后一行
        let last = editScript.last!
        if last.x < oldLines.count {
            result.append(DiffLine(
                content: oldLines[last.x],
                type: .removed,
                oldLineNumber: last.x + 1,
                newLineNumber: nil
            ))
        }
        if last.y < newLines.count {
            result.append(DiffLine(
                content: newLines[last.y],
                type: .added,
                oldLineNumber: nil,
                newLineNumber: last.y + 1
            ))
        }

        return result
    }

    // MARK: - Data Structures

    /// 表示图中的一个点
    private struct Point {
        let x: Int  // 旧文本中的位置
        let y: Int  // 新文本中的位置
    }
}
