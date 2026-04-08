import Foundation

/// 差异类型
public enum DiffType {
    case unchanged
    case added
    case removed
    case modified
}

/// Hunk Header 的扩展方向
/// 参考 GitHub Desktop 的 `DiffHunkExpansionType`
public enum HunkExpansionType: Sendable {
    /// 不能扩展
    case none
    /// 只能向上扩展（首个 hunk）
    case up
    /// 只能向下扩展（末尾 hunk）
    case down
    /// 可双向扩展（hunk 之间的 gap > 20 行）
    case both
    /// gap 较短（≤ 20 行），展开时会与相邻 hunk 合并
    case short
}

/// 字符级差异范围，用于行内高亮
/// 参考 GitHub Desktop 的 `changed-range.ts` 中的 `IRange`
public struct CharRange: Sendable {
    public let location: Int
    public let length: Int

    public init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }

    public var endLocation: Int {
        location + length
    }
}

/// 差异行数据
public struct DiffLine {
    let content: String
    let type: DiffType
    let oldLineNumber: Int?
    let newLineNumber: Int?
    /// 行级高亮范围（整行背景色）
    let highlightRanges: [Range<String.Index>]?
    /// 字符级高亮范围（行内差异部分的背景色）
    var charHighlightRanges: [CharRange]?

    init(content: String, type: DiffType, oldLineNumber: Int?, newLineNumber: Int?, highlightRanges: [Range<String.Index>]? = nil, charHighlightRanges: [CharRange]? = nil) {
        self.content = content
        self.type = type
        self.oldLineNumber = oldLineNumber
        self.newLineNumber = newLineNumber
        self.highlightRanges = highlightRanges
        self.charHighlightRanges = charHighlightRanges
    }
}

/// Hunk Header 数据（`@@ -oldStart,oldCount +newStart,newCount @@`）
/// 参考 GitHub Desktop 的 `DiffHunkHeader`
public struct HunkHeader: Sendable {
    public let oldStartLine: Int
    public let oldLineCount: Int
    public let newStartLine: Int
    public let newLineCount: Int

    public init(oldStartLine: Int, oldLineCount: Int, newStartLine: Int, newLineCount: Int) {
        self.oldStartLine = oldStartLine
        self.oldLineCount = oldLineCount
        self.newStartLine = newStartLine
        self.newLineCount = newLineCount
    }

    /// 生成 hunk header 的文本表示
    public func toDiffLineRepresentation() -> String {
        "@@ -\(oldStartLine),\(oldLineCount) +\(newStartLine),\(newLineCount) @@"
    }

    /// 获取简洁的上下文信息（用于折叠块显示）
    public var contextInfo: String {
        toDiffLineRepresentation()
    }
}

/// 折叠块数据
public struct CollapsibleBlock {
    let lines: [DiffLine]
    let isCollapsed: Bool
    let startLineNumber: Int
    let endLineNumber: Int
    let contextInfo: String?
    /// 折叠块的扩展类型
    let expansionType: HunkExpansionType
    /// 折叠块隐藏的行数（向上隐藏的行数 + 向下隐藏的行数）
    let hiddenLineCount: Int

    /// 创建折叠块
    init(lines: [DiffLine], isCollapsed: Bool = true, startLineNumber: Int, endLineNumber: Int, contextInfo: String? = nil, expansionType: HunkExpansionType = .both, hiddenLineCount: Int = 0) {
        self.lines = lines
        self.isCollapsed = isCollapsed
        self.startLineNumber = startLineNumber
        self.endLineNumber = endLineNumber
        self.contextInfo = contextInfo
        self.expansionType = expansionType
        self.hiddenLineCount = hiddenLineCount
    }
}

/// 差异项目类型（可以是单行、hunk header 或折叠块）
public enum DiffItem {
    case line(DiffLine)
    case collapsibleBlock(CollapsibleBlock)
    case hunkHeader(HunkHeader)
}
