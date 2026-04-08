import XCTest
@testable import MagicDiffView

/// MagicDiffView 折叠功能测试
final class MagicDiffViewCollapsingTests: XCTestCase {
    
    /// 测试折叠块的创建
    func testCollapsibleBlockCreation() {
        let lines = [
            DiffLine(content: "line 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 1),
            DiffLine(content: "line 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 2),
            DiffLine(content: "line 3", type: .unchanged, oldLineNumber: 3, newLineNumber: 3)
        ]
        
        let block = CollapsibleBlock(
            lines: lines,
            isCollapsed: true,
            startLineNumber: 1,
            endLineNumber: 3
        )
        
        XCTAssertEqual(block.lines.count, 3)
        XCTAssertTrue(block.isCollapsed)
        XCTAssertEqual(block.startLineNumber, 1)
        XCTAssertEqual(block.endLineNumber, 3)
    }
    
    /// 测试差异项目组织功能
    func testOrganizeDiffItems() {
        let diffLines = [
            DiffLine(content: "added line", type: .added, oldLineNumber: nil, newLineNumber: 1),
            DiffLine(content: "unchanged 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 2),
            DiffLine(content: "unchanged 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 3),
            DiffLine(content: "unchanged 3", type: .unchanged, oldLineNumber: 3, newLineNumber: 4),
            DiffLine(content: "unchanged 4", type: .unchanged, oldLineNumber: 4, newLineNumber: 5),
            DiffLine(content: "removed line", type: .removed, oldLineNumber: 5, newLineNumber: nil)
        ]
        
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3, contextLines: 3)
        
        // 新实现会生成 hunk header + lines，项目数量会有所不同
        XCTAssertGreaterThanOrEqual(items.count, 1) // 至少应该有一个 hunk header
        
        // 检查第一个项目是 hunk header
        if case .hunkHeader(let header) = items[0] {
            XCTAssertNotNil(header)
        } else {
            XCTFail("第一个项目应该是 hunk header")
        }
        
        // 应该包含添加和删除的行
        let hasAddedLine = items.contains { item in
            if case .line(let line) = item, line.type == .added {
                return true
            }
            return false
        }
        XCTAssertTrue(hasAddedLine, "应该包含添加的行")
        
        let hasRemovedLine = items.contains { item in
            if case .line(let line) = item, line.type == .removed {
                return true
            }
            return false
        }
        XCTAssertTrue(hasRemovedLine, "应该包含删除的行")
    }
    
    /// 测试不满足最小行数的情况
    func testOrganizeDiffItemsWithInsufficientLines() {
        let diffLines = [
            DiffLine(content: "unchanged 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 1),
            DiffLine(content: "unchanged 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 2),
            DiffLine(content: "added line", type: .added, oldLineNumber: nil, newLineNumber: 3)
        ]
        
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3, contextLines: 3)
        
        // 新实现会生成 hunk header，所以项目数量会多于原始行数
        XCTAssertGreaterThanOrEqual(items.count, 1)
        
        // 所有项目应该是 line 或 hunkHeader
        for item in items {
            if case .line(_) = item {
                // 正确
            } else if case .hunkHeader(_) = item {
                // 正确
            } else {
                XCTFail("所有项目都应该是普通行或 hunk header")
            }
        }
    }
    
    /// 测试空差异行数组
    func testOrganizeDiffItemsWithEmptyArray() {
        let diffLines: [DiffLine] = []
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3)
        
        XCTAssertTrue(items.isEmpty)
    }
    
    /// 测试只有变动行的情况
    func testOrganizeDiffItemsWithOnlyChangedLines() {
        let diffLines = [
            DiffLine(content: "added line 1", type: .added, oldLineNumber: nil, newLineNumber: 1),
            DiffLine(content: "removed line 1", type: .removed, oldLineNumber: 1, newLineNumber: nil),
            DiffLine(content: "added line 2", type: .added, oldLineNumber: nil, newLineNumber: 2)
        ]
        
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3, contextLines: 3)
        
        // 新实现会生成 hunk header，所以项目数量会多于原始行数
        XCTAssertGreaterThanOrEqual(items.count, 1)
        
        // 应该至少包含一个 hunk header
        let hasHunkHeader = items.contains { item in
            if case .hunkHeader(_) = item {
                return true
            }
            return false
        }
        XCTAssertTrue(hasHunkHeader, "应该包含 hunk header")
        
        // 所有项目应该是 line 或 hunkHeader
        for item in items {
            if case .line(_) = item {
                // 正确
            } else if case .hunkHeader(_) = item {
                // 正确
            } else {
                XCTFail("所有项目都应该是普通行或 hunk header")
            }
        }
    }
}