import Foundation

/// 差异类型
public enum DiffType {
    case unchanged
    case added
    case removed
    case modified
}

/// 差异行数据
public struct DiffLine {
    let content: String
    let type: DiffType
    let oldLineNumber: Int?
    let newLineNumber: Int?
    let highlightRanges: [Range<String.Index>]?
    
    init(content: String, type: DiffType, oldLineNumber: Int?, newLineNumber: Int?, highlightRanges: [Range<String.Index>]? = nil) {
        self.content = content
        self.type = type
        self.oldLineNumber = oldLineNumber
        self.newLineNumber = newLineNumber
        self.highlightRanges = highlightRanges
    }
}

/// 折叠块数据
public struct CollapsibleBlock {
    let lines: [DiffLine]
    let isCollapsed: Bool
    let startLineNumber: Int
    let endLineNumber: Int
    
    let contextInfo: String?
    
    /// 创建折叠块
    /// - Parameters:
    ///   - lines: 包含的差异行
    ///   - isCollapsed: 是否折叠状态
    ///   - startLineNumber: 起始行号
    ///   - endLineNumber: 结束行号
    ///   - contextInfo: 上下文信息（如函数名）
    init(lines: [DiffLine], isCollapsed: Bool = true, startLineNumber: Int, endLineNumber: Int, contextInfo: String? = nil) {
        self.lines = lines
        self.isCollapsed = isCollapsed
        self.startLineNumber = startLineNumber
        self.endLineNumber = endLineNumber
        self.contextInfo = contextInfo
    }
}

/// 差异项目类型（可以是单行或折叠块）
public enum DiffItem {
    case line(DiffLine)
    case collapsibleBlock(CollapsibleBlock)
}

/// 差异算法版本
public enum DiffAlgorithmVersion: String, CaseIterable {
    /// 原始的双指针算法（默认）
    case legacy = "Legacy"

    /// Myers 算法（推荐，性能更好）
    case myers = "Myers"

    /// 自动选择（根据文件大小自动选择最合适的算法）
    case auto = "Auto"

    /// 算法描述
    public var description: String {
        switch self {
        case .legacy:
            return "传统双指针算法（适合小文件）"
        case .myers:
            return "Myers 算法（推荐，大文件性能更好）"
        case .auto:
            return "自动选择（根据文件大小）"
        }
    }

    /// 算法复杂度描述
    public var complexity: String {
        switch self {
        case .legacy:
            return "O(m×n)"
        case .myers:
            return "O((m+n)×D)，D 为编辑距离"
        case .auto:
            return "自适应"
        }
    }
}