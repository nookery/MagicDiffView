import Foundation
import SwiftUI

/// 差异视图的显示模式
public enum ViewMode: String, CaseIterable {
    /// 显示差异比较视图
    case diff
    /// 显示并排对比视图
    case sideBySide
    /// 显示原始文本
    case original
    /// 显示新文本
    case modified

    /// 显示名称
    var displayName: String {
        switch self {
        case .diff:
            return "差异"
        case .sideBySide:
            return "并排"
        case .original:
            return "原文本"
        case .modified:
            return "新文本"
        }
    }

    /// 是否为对比模式
    var isComparisonMode: Bool {
        self == .diff || self == .sideBySide
    }
}

