import Foundation

/// 字符级差异计算工具
///
/// 参考 GitHub Desktop 的 `changed-range.ts` 中 `relativeChanges()` 实现
/// 通过计算两行字符串的公共前缀和公共后缀，找出差异范围。
struct InlineDiff {

    /// 计算两行字符串的差异范围
    /// - Parameters:
    ///   - stringA: 旧版本的行内容
    ///   - stringB: 新版本的行内容
    /// - Returns: 旧字符串中的差异范围和新字符串中的差异范围
    static func relativeChanges(_ stringA: String, _ stringB: String) -> (rangeA: CharRange, rangeB: CharRange) {
        var rangeB = CharRange(location: 0, length: stringB.count)
        var rangeA = CharRange(location: 0, length: stringA.count)

        // 去掉公共前缀
        let prefixLength = commonLength(stringA, rangeA, stringB, rangeB, reverse: false)
        rangeA = CharRange(location: rangeA.location + prefixLength, length: rangeA.length - prefixLength)
        rangeB = CharRange(location: rangeB.location + prefixLength, length: rangeB.length - prefixLength)

        // 去掉公共后缀
        let suffixLength = commonLength(stringA, rangeA, stringB, rangeB, reverse: true)
        rangeA = CharRange(location: rangeA.location, length: rangeA.length - suffixLength)
        rangeB = CharRange(location: rangeB.location, length: rangeB.length - suffixLength)

        return (rangeA, rangeB)
    }

    /// 计算两个字符串在指定范围内的公共长度
    /// - Parameters:
    ///   - stringA: 第一个字符串
    ///   - rangeA: 第一个字符串的范围
    ///   - stringB: 第二个字符串
    ///   - rangeB: 第二个字符串的范围
    ///   - reverse: 是否从末尾开始计算
    /// - Returns: 公共字符的长度
    private static func commonLength(
        _ stringA: String, _ rangeA: CharRange,
        _ stringB: String, _ rangeB: CharRange,
        reverse: Bool
    ) -> Int {
        let aChars = Array(stringA)
        let bChars = Array(stringB)

        let maxLen = min(rangeA.length, rangeB.length)
        let startA = reverse ? rangeA.endLocation - 1 : rangeA.location
        let startB = reverse ? rangeB.endLocation - 1 : rangeB.location
        let stride = reverse ? -1 : 1

        var length = 0
        var i = 0
        while abs(length) < maxLen {
            let ai = startA + i * stride
            let bi = startB + i * stride
            guard ai >= 0, ai < aChars.count,
                  bi >= 0, bi < bChars.count else { break }
            if aChars[ai] != bChars[bi] { break }
            length += stride
            i += 1
        }

        return abs(length)
    }

    /// 为连续的 added/removed 行对生成字符级高亮范围
    /// 参考 GitHub Desktop 的 `getModifiedRows()` 中 `getDiffTokens()` 逻辑
    /// - Parameters:
    ///   - deletedLines: 被删除的行
    ///   - addedLines: 被添加的行（与删除行一一对应）
    ///   - maxLineLength: 超过此长度的行不进行字符级高亮（与 GitHub Desktop 一致，默认 1024）
    /// - Returns: 包含字符级高亮范围的行数组
    static func computeCharHighlightRanges(
        deletedLines: [DiffLine],
        addedLines: [DiffLine],
        maxLineLength: Int = 1024
    ) -> (deletedResult: [DiffLine], addedResult: [DiffLine]) {
        // 仅在 added 和 deleted 行数相等时才进行字符级高亮
        guard deletedLines.count == addedLines.count else {
            return (deletedLines, addedLines)
        }

        var newDeleted = [DiffLine]()
        var newAdded = [DiffLine]()

        for i in 0..<deletedLines.count {
            let delLine = deletedLines[i]
            let addLine = addedLines[i]

            // 行过长时跳过字符级高亮
            guard delLine.content.count < maxLineLength,
                  addLine.content.count < maxLineLength else {
                newDeleted.append(delLine)
                newAdded.append(addLine)
                continue
            }

            let (rangeA, rangeB) = relativeChanges(delLine.content, addLine.content)

            var updatedDelLine = delLine
            updatedDelLine.charHighlightRanges = rangeA.length > 0 ? [rangeA] : nil

            var updatedAddLine = addLine
            updatedAddLine.charHighlightRanges = rangeB.length > 0 ? [rangeB] : nil

            newDeleted.append(updatedDelLine)
            newAdded.append(updatedAddLine)
        }

        return (newDeleted, newAdded)
    }
}
