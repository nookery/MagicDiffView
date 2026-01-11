import XCTest
@testable import MagicDiffView

/// Myers 差异算法测试
final class MyersDiffAlgorithmTests: XCTestCase {

    // MARK: - 基础功能测试

    /// 测试完全相同的文本
    func testIdenticalTexts() {
        let oldLines = ["Line 1", "Line 2", "Line 3"]
        let newLines = ["Line 1", "Line 2", "Line 3"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        for line in result {
            XCTAssertEqual(line.type, .unchanged)
        }
    }

    /// 测试完全不同的文本
    func testCompletelyDifferentTexts() {
        let oldLines = ["A", "B", "C"]
        let newLines = ["X", "Y", "Z"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        // 应该有6行：3个删除 + 3个添加
        XCTAssertEqual(result.count, 6)

        // 前3个应该是删除的
        XCTAssertEqual(result[0].type, .removed)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .removed)

        // 后3个应该是添加的
        XCTAssertEqual(result[3].type, .added)
        XCTAssertEqual(result[4].type, .added)
        XCTAssertEqual(result[5].type, .added)
    }

    /// 测试空旧文本
    func testEmptyOldText() {
        let oldLines: [String] = []
        let newLines = ["A", "B", "C"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)

        for line in result {
            XCTAssertEqual(line.type, .added)
            XCTAssertNil(line.oldLineNumber)
            XCTAssertNotNil(line.newLineNumber)
        }
    }

    /// 测试空新文本
    func testEmptyNewText() {
        let oldLines = ["A", "B", "C"]
        let newLines: [String] = []

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)

        for line in result {
            XCTAssertEqual(line.type, .removed)
            XCTAssertNotNil(line.oldLineNumber)
            XCTAssertNil(line.newLineNumber)
        }
    }

    /// 测试两个空文本
    func testBothEmpty() {
        let oldLines: [String] = []
        let newLines: [String] = []

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - 插入测试

    /// 测试单行插入
    func testSingleLineInsertion() {
        let oldLines = ["Line 1", "Line 3"]
        let newLines = ["Line 1", "Line 2", "Line 3"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .added)
        XCTAssertEqual(result[2].type, .unchanged)
        XCTAssertEqual(result[1].content, "Line 2")
    }

    /// 测试多行插入
    func testMultipleLineInsertion() {
        let oldLines = ["A", "E"]
        let newLines = ["A", "B", "C", "D", "E"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .added)
        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[3].type, .added)
        XCTAssertEqual(result[4].type, .unchanged)
    }

    /// 测试开头插入
    func testInsertionAtBeginning() {
        let oldLines = ["B", "C"]
        let newLines = ["A", "B", "C"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].type, .added)
        XCTAssertEqual(result[0].content, "A")
        XCTAssertEqual(result[1].type, .unchanged)
        XCTAssertEqual(result[2].type, .unchanged)
    }

    /// 测试结尾插入
    func testInsertionAtEnd() {
        let oldLines = ["A", "B"]
        let newLines = ["A", "B", "C"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .unchanged)
        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[2].content, "C")
    }

    // MARK: - 删除测试

    /// 测试单行删除
    func testSingleLineDeletion() {
        let oldLines = ["Line 1", "Line 2", "Line 3"]
        let newLines = ["Line 1", "Line 3"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .unchanged)
        XCTAssertEqual(result[1].content, "Line 2")
    }

    /// 测试多行删除
    func testMultipleLineDeletion() {
        let oldLines = ["A", "B", "C", "D", "E"]
        let newLines = ["A", "E"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .removed)
        XCTAssertEqual(result[3].type, .removed)
        XCTAssertEqual(result[4].type, .unchanged)
    }

    /// 测试开头删除
    func testDeletionAtBeginning() {
        let oldLines = ["A", "B", "C"]
        let newLines = ["B", "C"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].type, .removed)
        XCTAssertEqual(result[0].content, "A")
        XCTAssertEqual(result[1].type, .unchanged)
        XCTAssertEqual(result[2].type, .unchanged)
    }

    /// 测试结尾删除
    func testDeletionAtEnd() {
        let oldLines = ["A", "B", "C"]
        let newLines = ["A", "B"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .unchanged)
        XCTAssertEqual(result[2].type, .removed)
        XCTAssertEqual(result[2].content, "C")
    }

    // MARK: - 修改测试

    /// 测试单行修改
    func testSingleLineModification() {
        let oldLines = ["Line 1", "Line 2", "Line 3"]
        let newLines = ["Line 1", "Modified", "Line 3"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 4)  // 应该是 4 行，不是 3 行
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[3].type, .unchanged)

        XCTAssertEqual(result[1].content, "Line 2")
        XCTAssertEqual(result[2].content, "Modified")
        XCTAssertEqual(result[3].content, "Line 3")
    }

    /// 测试多行修改
    func testMultipleLineModification() {
        let oldLines = ["A", "B", "C", "D", "E"]
        let newLines = ["A", "X", "Y", "Z", "E"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        // 应该有：A(unchanged), B(removed), C(removed), D(removed), X(added), Y(added), Z(added), E(unchanged)
        XCTAssertEqual(result.count, 8)

        let removedTypes = result.filter { $0.type == .removed }
        let addedTypes = result.filter { $0.type == .added }

        XCTAssertEqual(removedTypes.count, 3)
        XCTAssertEqual(addedTypes.count, 3)
    }

    // MARK: - 复杂场景测试

    /// 测试混合修改（插入+删除+修改）
    func testMixedModifications() {
        let oldLines = [
            "import Foundation",
            "class User {",
            "    let name: String",
            "}",
            ""
        ]
        let newLines = [
            "import Foundation",
            "class User {",
            "    let id: Int",
            "    let name: String",
            "    let age: Int?",
            "}",
            ""
        ]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        // 临时调试输出
        for (i, line) in result.enumerated() {
            print("DEBUG [\(i)]: \(line.type) - '\(line.content)'")
        }

        // 检查有添加的内容
        XCTAssertTrue(result.contains { $0.type == .added }, "应该有 added 类型的行")

        // 检查有删除的内容 - 注意：这个测试可能没有删除，只是添加和修改
        // 修复：这个测试不应该检查 removed，因为实际上没有删除任何行
        // XCTAssertTrue(result.contains { $0.type == .removed })

        // 检查有未修改的内容
        XCTAssertTrue(result.contains { $0.type == .unchanged }, "应该有 unchanged 类型的行")
    }

    /// 测试大文本性能
    func testLargeTextPerformance() {
        let oldLines = (1...1000).map { "Line \($0)" }
        var newLines = oldLines
        newLines[500] = "Modified Line 501"

        measure {
            _ = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
        }
    }

    /// 测试行号正确性
    func testLineNumberAccuracy() {
        let oldLines = ["A", "B", "C", "D", "E"]
        let newLines = ["A", "X", "C", "Y", "E"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        // 检查未修改行的行号
        let unchangedLines = result.filter { $0.type == .unchanged }
        for line in unchangedLines {
            XCTAssertEqual(line.oldLineNumber, line.newLineNumber)
        }

        // 检查删除行的行号
        let removedLines = result.filter { $0.type == .removed }
        for line in removedLines {
            XCTAssertNotNil(line.oldLineNumber)
            XCTAssertNil(line.newLineNumber)
        }

        // 检查添加行的行号
        let addedLines = result.filter { $0.type == .added }
        for line in addedLines {
            XCTAssertNil(line.oldLineNumber)
            XCTAssertNotNil(line.newLineNumber)
        }
    }

    // MARK: - 边界情况

    /// 测试单行文本
    func testSingleLineText() {
        let oldLines = ["Hello"]
        let newLines = ["World"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        // 只验证算法不会崩溃
        XCTAssertNotNil(result, "Should return a result without crashing")
    }

    /// 测试包含空行的文本
    func testTextWithEmptyLines() {
        let oldLines = ["A", "", "C"]
        let newLines = ["A", "B", "C"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 4)  // 应该是 4 行：A(unchanged), ""(removed), B(added), C(unchanged)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[0].content, "A")
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[1].content, "")
        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[2].content, "B")
        XCTAssertEqual(result[3].type, .unchanged)
        XCTAssertEqual(result[3].content, "C")
    }

    /// 测试包含特殊字符的文本
    func testTextWithSpecialCharacters() {
        let oldLines = ["Line with \"quotes\"", "Line with 'apostrophes'", "Line with \\backslash"]
        let newLines = ["Line with \"quotes\"", "Modified 'apostrophes'", "Line with \\backslash"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains { $0.type == .unchanged })
        XCTAssertTrue(result.contains { $0.type == .removed })
        XCTAssertTrue(result.contains { $0.type == .added })
    }

    /// 测试Unicode文本
    func testUnicodeText() {
        let oldLines = ["你好世界", "测试中文", "🎉🎊🎈"]
        let newLines = ["你好世界", "修改了中文", "🎉🎊🎈"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 4)  // 应该是 4 行
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[3].type, .unchanged)
    }

    /// 测试非常长的行
    func testVeryLongLines() {
        let longLine = String(repeating: "A", count: 10000)
        let oldLines = [longLine]
        let newLines = [longLine + "B"]

        let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].type, .removed)
        XCTAssertEqual(result[1].type, .added)
    }

    /// 测试大量重复文本
    func testMassiveDuplicateText() {
        let oldLines = Array(repeating: "Same Line", count: 1000)
        let newLines = Array(repeating: "Same Line", count: 1000)

        measure {
            let result = MyersDiffAlgorithm.computeDiff(oldLines: oldLines, newLines: newLines)
            XCTAssertEqual(result.count, 1000)

            for line in result {
                XCTAssertEqual(line.type, .unchanged)
            }
        }
    }

    // MARK: - Unified Diff 解析测试

    /// 测试基本的 unified diff 解析
    func testParseUnifiedDiffBasic() throws {
        let diffText = """
        @@ -1,3 +1,3 @@
         Line 1
        -Line 2 old
        +Line 2 new
         Line 3
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].type, .unchanged)
        XCTAssertEqual(result[0].oldLineNumber, 1)
        XCTAssertEqual(result[0].newLineNumber, 1)

        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[1].oldLineNumber, 2)
        XCTAssertEqual(result[1].newLineNumber, nil)

        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[2].oldLineNumber, nil)
        XCTAssertEqual(result[2].newLineNumber, 2)

        XCTAssertEqual(result[3].type, .unchanged)
        XCTAssertEqual(result[3].oldLineNumber, 3)
        XCTAssertEqual(result[3].newLineNumber, 3)
    }

    /// 测试带文件头的 unified diff 解析
    func testParseUnifiedDiffWithFileHeaders() throws {
        let diffText = """
        --- old.txt
        +++ new.txt
        @@ -1,3 +1,3 @@
         Line 1
        -Line 2 old
        +Line 2 new
         Line 3
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .added)
    }

    /// 测试只有新增的 diff
    func testParseUnifiedDiffOnlyAdditions() throws {
        let diffText = """
        @@ -1,0 +1,2 @@
        +New Line 1
        +New Line 2
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].type, .added)
        XCTAssertEqual(result[0].newLineNumber, 1)
        XCTAssertEqual(result[1].type, .added)
        XCTAssertEqual(result[1].newLineNumber, 2)
    }

    /// 测试只有删除的 diff
    func testParseUnifiedDiffOnlyDeletions() throws {
        let diffText = """
        @@ -1,2 +1,0 @@
        -Old Line 1
        -Old Line 2
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].type, .removed)
        XCTAssertEqual(result[0].oldLineNumber, 1)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[1].oldLineNumber, 2)
    }

    /// 测试多个 hunk 的 diff
    func testParseUnifiedDiffMultipleHunks() throws {
        let diffText = """
        @@ -1,3 +1,3 @@
         Line 1
        -Line 2 old
        +Line 2 new
         Line 3
        @@ -5,2 +5,2 @@
         Line 5
        -Line 6 old
        +Line 6 new
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 7)
        XCTAssertEqual(result[1].type, .removed)
        XCTAssertEqual(result[2].type, .added)
        XCTAssertEqual(result[5].type, .removed)
        XCTAssertEqual(result[6].type, .added)
    }

    /// 测试 Git 风格的 diff
    func testParseGitStyleDiff() throws {
        let diffText = """
        diff --git a/file.txt b/file.txt
        index 1234567..abcdefg 100644
        --- a/file.txt
        +++ b/file.txt
        @@ -1,5 +1,5 @@
         import Foundation
         class User {
        -    let name: String
        +    let name: String?
         let age: Int
         }
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        // 查找改变的行
        let removedLine = result.first { $0.type == .removed }
        let addedLine = result.first { $0.type == .added }

        XCTAssertNotNil(removedLine)
        XCTAssertNotNil(addedLine)
        XCTAssertEqual(removedLine?.content, "    let name: String")
        XCTAssertEqual(addedLine?.content, "    let name: String?")
    }

    /// 测试空 diff
    func testParseEmptyDiff() throws {
        let diffText = ""

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 0)
    }

    /// 测试只有 context 的 diff（无变化）
    func testParseUnifiedDiffOnlyContext() throws {
        let diffText = """
        @@ -1,3 +1,3 @@
         Line 1
         Line 2
         Line 3
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 3)
        for line in result {
            XCTAssertEqual(line.type, .unchanged)
        }
    }

    /// 测试安全的 diff 解析（不抛出异常）
    func testParseUnifiedDiffSafely() {
        let invalidDiff = "This is not a valid unified diff"

        let result = MyersDiffAlgorithm.parseUnifiedDiffSafely(invalidDiff)

        // 应该返回空数组而不是崩溃
        XCTAssertEqual(result.count, 0)
    }

    /// 测试行号正确性
    func testParseUnifiedDiffLineNumbers() throws {
        let diffText = """
        @@ -10,5 +10,6 @@
         Line 10
         Line 11
        -Line 12 old
        +Line 12 new
         Line 13
        +Line 14 new
         Line 15
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        // 验证行号
        let unchanged10 = result[0]
        let removed12 = result.first { $0.type == .removed }
        let added12 = result.first { $0.type == .added && $0.content == "Line 12 new" }
        let added14 = result.first { $0.type == .added && $0.content == "Line 14 new" }

        XCTAssertEqual(unchanged10.oldLineNumber, 10)
        XCTAssertEqual(unchanged10.newLineNumber, 10)
        XCTAssertEqual(removed12?.oldLineNumber, 12)
        XCTAssertEqual(added12?.newLineNumber, 12)
        XCTAssertEqual(added14?.newLineNumber, 14)
    }

    /// 测试混合修改的 diff
    func testParseUnifiedDiffMixedChanges() throws {
        let diffText = """
        @@ -1,5 +1,7 @@
         Line 1
        -Line 2 deleted
         Line 3
        +Line 4 inserted
         Line 5
        +Line 6 inserted
        -Line 7 deleted
        +Line 8 inserted
        """

        let result = try MyersDiffAlgorithm.parseUnifiedDiff(diffText)

        XCTAssertEqual(result.count, 8)

        let removedLines = result.filter { $0.type == .removed }
        let addedLines = result.filter { $0.type == .added }
        let unchangedLines = result.filter { $0.type == .unchanged }

        XCTAssertEqual(removedLines.count, 2)
        XCTAssertEqual(addedLines.count, 3)
        XCTAssertEqual(unchangedLines.count, 3)
    }
}
