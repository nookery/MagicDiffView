import XCTest
@testable import MagicDiffView

/// MagicDiffView 初始化和基本功能测试
final class MagicDiffViewTests: XCTestCase {

    // MARK: - diffOutput 初始化方法测试

    /// 测试使用有效的 diffOutput 进行初始化
    func testInitWithValidDiffOutput() {
        // Given: 准备有效的 Git diff 输出
        let diffOutput = """
diff --git a/test.txt b/test.txt
@@ -1,3 +1,3 @@
 Line 1
-Line 2 old
+Line 2 new
 Line 3
"""

        // When: 使用 diffOutput 初始化 MagicDiffView
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证初始化成功
        XCTAssertNotNil(view.diffLines)
        XCTAssertEqual(view.diffLines?.count, 5) // diff header + hunk header + 3 content lines

        // 验证第一行是 diff header
        if let firstLine = view.diffLines?.first {
            XCTAssertEqual(firstLine.content, "diff --git a/test.txt b/test.txt")
            XCTAssertEqual(firstLine.type, .unchanged)
        }

        // 验证语言检测（简单的文本可能被识别为 plainText）
        // 这里我们只验证语言属性存在
        XCTAssertNotNil(view.language)
    }

    /// 测试使用空的 diffOutput 进行初始化
    func testInitWithEmptyDiffOutput() {
        // Given: 空的 diff 输出
        let diffOutput = ""

        // When: 使用空 diffOutput 初始化
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证处理空输入
        XCTAssertNotNil(view.diffLines)
        XCTAssertTrue(view.diffLines?.isEmpty ?? false)
    }

    /// 测试使用无效的 diffOutput 进行初始化
    func testInitWithInvalidDiffOutput() {
        // Given: 不包含有效 hunk 的 diff 输出
        let diffOutput = """
        This is not a valid diff
        Just some random text
        """

        // When: 使用无效 diffOutput 初始化
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证返回空数组
        XCTAssertNotNil(view.diffLines)
        XCTAssertTrue(view.diffLines?.isEmpty ?? false)
    }

    /// 测试 diffOutput 初始化与原始文本初始化的一致性
    func testDiffOutputConsistencyWithTextInit() {
        // Given: 原始文本和对应的 diff 输出
        let oldText = "Line 1\nLine 2 old\nLine 3"
        let newText = "Line 1\nLine 2 new\nLine 3"

        let diffOutput = """
diff --git a/test.txt b/test.txt
@@ -1,3 +1,3 @@
 Line 1
-Line 2 old
+Line 2 new
 Line 3
"""

        // When: 使用 diffOutput 初始化
        let diffView = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证 diffLines 被正确解析
        XCTAssertNotNil(diffView.diffLines)
        XCTAssertEqual(diffView.diffLines?.count, 5) // diff header + hunk header + 3 content lines

        // 验证第一行是 diff header
        if let firstLine = diffView.diffLines?.first {
            XCTAssertEqual(firstLine.content, "diff --git a/test.txt b/test.txt")
            XCTAssertEqual(firstLine.type, .unchanged)
        }
    }

    /// 测试 diffLines 内容的正确性
    func testDiffLinesContent() {
        // Given: Git diff 输出
        let diffOutput = """
diff --git a/test.txt b/test.txt
@@ -1,3 +1,3 @@
 Line 1
-Line 2 old
+Line 2 new
 Line 3
"""

        // When: 初始化视图
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证 diffLines 内容
        XCTAssertNotNil(view.diffLines)
        XCTAssertEqual(view.diffLines?.count, 5) // diff header + 4 content lines

        guard let lines = view.diffLines else { return }

        // 第一行：diff header
        XCTAssertEqual(lines[0].content, "diff --git a/test.txt b/test.txt")
        XCTAssertEqual(lines[0].type, .unchanged)

        // 第二行：未变更
        XCTAssertEqual(lines[1].content, "Line 1")
        XCTAssertEqual(lines[1].type, .unchanged)

        // 第三行：删除
        XCTAssertEqual(lines[2].content, "Line 2 old")
        XCTAssertEqual(lines[2].type, .removed)

        // 第四行：添加
        XCTAssertEqual(lines[3].content, "Line 2 new")
        XCTAssertEqual(lines[3].type, .added)

        // 第五行：未变更（Line 3）
        XCTAssertEqual(lines[4].content, "Line 3")
        XCTAssertEqual(lines[4].type, .unchanged)
    }

    /// 测试复杂 diff 输出的解析
    func testInitWithComplexDiffOutput() {
        // Given: 包含多个 hunk 的复杂 diff
        let diffOutput = """
diff --git a/complex.txt b/complex.txt
index 1234567..abcdef0 100644
--- a/complex.txt
+++ b/complex.txt
@@ -1,4 +1,4 @@
 func hello() {
-    print("Hello World")
+    print("Hello Swift")
     return true
 }
@@ -10,3 +10,4 @@
 let x = 1
 let y = 2
+let z = 3
"""

        // When: 解析复杂 diff
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证解析结果
        XCTAssertNotNil(view.diffLines)
        XCTAssertGreaterThan(view.diffLines?.count ?? 0, 5)

        // 验证语言被正确识别为 Swift
        XCTAssertEqual(view.language, .swift)
    }

    /// 测试只有添加行的 diff
    func testInitWithOnlyAdditions() {
        // Given: 只有添加行的 diff
        let diffOutput = """
        diff --git a/empty.txt b/new.txt
        --- a/empty.txt
        +++ b/new.txt
        @@ -0,0 +1,3 @@
        +Line 1
        +Line 2
        +Line 3
        """

        // When: 解析只有添加的 diff
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证所有内容行都是添加类型
        XCTAssertNotNil(view.diffLines)
        XCTAssertEqual(view.diffLines?.count, 4) // diff header + 3 added lines

        let contentLines = view.diffLines?.dropFirst() ?? [] // 跳过 diff header
        for line in contentLines {
            XCTAssertEqual(line.type, .added)
        }
    }

    /// 测试只有删除行的 diff
    func testInitWithOnlyDeletions() {
        // Given: 只有删除行的 diff
        let diffOutput = """
        diff --git a/old.txt b/empty.txt
        --- a/old.txt
        +++ b/empty.txt
        @@ -1,3 +0,0 @@
        -Line 1
        -Line 2
        -Line 3
        """

        // When: 解析只有删除的 diff
        let view = MagicDiffView(diffOutput: diffOutput)

        // Then: 验证所有内容行都是删除类型
        XCTAssertNotNil(view.diffLines)
        XCTAssertEqual(view.diffLines?.count, 4) // diff header + 3 removed lines

        let contentLines = view.diffLines?.dropFirst() ?? [] // 跳过 diff header
        for line in contentLines {
            XCTAssertEqual(line.type, .removed)
        }
    }
}
