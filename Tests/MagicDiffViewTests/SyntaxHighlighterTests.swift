import XCTest
import SwiftUI
@testable import MagicDiffView

/// 语法高亮器测试
final class SyntaxHighlighterTests: XCTestCase {

    // MARK: - 语言检测测试

    /// 测试 Swift 代码检测
    func testSwiftLanguageDetection() {
        let swiftCodes = [
            "import SwiftUI\nstruct ContentView: View { }",
            "import Foundation\nlet x = 1",
            "@State private var count = 0",
            "struct MyView: View { var body: some View { Text(\"Hi\") } }"
        ]

        for code in swiftCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .swift, "Failed to detect Swift code: \(code)")
        }
    }

    /// 测试 JavaScript 代码检测
    func testJavaScriptLanguageDetection() {
        let jsCodes = [
            "const items = [];\nfunction test() { }",
            "let x = 1;\nconst y = 2;",
            "import React from 'react';\nexport default function App() { }",
            "const add = (a, b) => a + b;"
        ]

        for code in jsCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .javascript, "Failed to detect JavaScript code: \(code)")
        }
    }

    /// 测试 Python 代码检测
    func testPythonLanguageDetection() {
        let pythonCodes = [
            "def hello():\n    print('Hello')",
            "import os\nfrom sys import argv",
            "class MyClass:\n    def __init__(self):\n        self.x = 1",
            "#!/usr/bin/env python\nprint('Hello')"
        ]

        for code in pythonCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .python, "Failed to detect Python code: \(code)")
        }
    }

    /// 测试 Java 代码检测
    func testJavaLanguageDetection() {
        let javaCodes = [
            "public class Main {\n    public static void main(String[] args) { }\n}",
            "package com.example;\npublic class Test { }",
            "import java.util.List;\npublic class Test { }",
            "@Override\npublic void toString() { }"
        ]

        for code in javaCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .java, "Failed to detect Java code: \(code)")
        }
    }

    /// 测试 C++ 代码检测
    func testCppLanguageDetection() {
        let cppCodes = [
            "#include <iostream>\nint main() { return 0; }",
            "using namespace std;\n#include <vector>",
            "#include <stdio.h>\nint main() { }",
            "std::cout << \"Hello\" << std::endl;"
        ]

        for code in cppCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .cpp, "Failed to detect C++ code: \(code)")
        }
    }

    /// 测试 HTML 代码检测
    func testHTMLLanguageDetection() {
        let htmlCodes = [
            "<!DOCTYPE html>\n<html><body></body></html>",
            "<html>\n<head><title>Test</title></head>\n</html>",
            "<div class=\"container\">\n  <p>Hello</p>\n</div>",
            "<head>\n<meta charset=\"UTF-8\">\n</head>"
        ]

        for code in htmlCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .html, "Failed to detect HTML code: \(code)")
        }
    }

    /// 测试 CSS 代码检测
    func testCSSLanguageDetection() {
        let cssCodes = [
            ".container {\n  width: 100px;\n  height: 200px;\n}",
            "body {\n  margin: 0;\n  padding: 0;\n}",
            "#header {\n  background-color: #fff;\n}",
            ".btn {\n  font-size: 1em;\n  color: #333;\n}"
        ]

        for code in cssCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .css, "Failed to detect CSS code: \(code)")
        }
    }

    /// 测试 PHP 代码检测
    func testPHPLanguageDetection() {
        let phpCodes = [
            "<?php\necho 'Hello';\n?>",
            "<?php\nnamespace App;\nclass Test { }",
            "function test() {\n    $x = 1;\n    return $x;\n}",
            "<?php\nnamespace MyNamespace;\nfunction hello() { }"
        ]

        for code in phpCodes {
            let detected = SyntaxHighlighter.detectLanguage(code)
            XCTAssertEqual(detected, .php, "Failed to detect PHP code: \(code)")
        }
    }

    /// 测试纯文本检测
    func testPlainTextDetection() {
        let plainTexts = [
            "这是一段普通的中文文本",
            "This is plain English text",
            "Hello\nWorld\nHow are you?",
            "没有编程语言特征的文本内容"
        ]

        for text in plainTexts {
            let detected = SyntaxHighlighter.detectLanguage(text)
            XCTAssertEqual(detected, .plainText, "Should detect plain text: \(text)")
        }
    }

    // MARK: - 语法高亮规则测试

    /// 测试所有语言都有高亮规则
    func testAllLanguagesHaveRules() {
        let languages: [CodeLanguage] = [
            .swift, .javascript, .python, .java, .cpp,
            .html, .css, .php, .plainText
        ]

        for language in languages {
            let rules = language.rules
            if language == .plainText {
                XCTAssertTrue(rules.isEmpty, "Plain text should have no rules")
            } else {
                XCTAssertFalse(rules.isEmpty, "\(language) should have highlighting rules")
            }
        }
    }

    /// 测试 Swift 关键字高亮
    func testSwiftKeywordHighlighting() {
        let swiftCode = "class Test { func hello() { var x = 1 } }"
        let rules = CodeLanguage.swift.rules

        // 测试关键字高亮规则存在
        let keywordRule = rules.first { $0.pattern.contains("class|struct|func") }
        XCTAssertNotNil(keywordRule, "Swift should have keyword highlighting rule")

        // 验证能匹配到关键字
        let highlighted = SyntaxHighlighter.highlight(text: swiftCode, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试 JavaScript 字符串高亮
    func testJavaScriptStringHighlighting() {
        let jsCode = "const x = 'hello';\nconst y = \"world\";"
        let rules = CodeLanguage.javascript.rules

        // 测试字符串高亮规则存在
        let stringRule = rules.first { $0.pattern.contains("'|\"") }
        XCTAssertNotNil(stringRule, "JavaScript should have string highlighting rule")

        let highlighted = SyntaxHighlighter.highlight(text: jsCode, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试 Python 注释高亮
    func testPythonCommentHighlighting() {
        let pythonCode = "# This is a comment\nx = 1  # Another comment"
        let rules = CodeLanguage.python.rules

        // 测试注释高亮规则存在
        let commentRule = rules.first { $0.pattern.contains("#") }
        XCTAssertNotNil(commentRule, "Python should have comment highlighting rule")

        let highlighted = SyntaxHighlighter.highlight(text: pythonCode, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试数字高亮
    func testNumberHighlighting() {
        let testCases = [
            (CodeLanguage.swift, "let x = 123"),
            (CodeLanguage.javascript, "const x = 123.45"),
            (CodeLanguage.python, "x = 100"),
            (CodeLanguage.java, "int x = 123;")
        ]

        for (language, code) in testCases {
            let rules = language.rules
            let numberRule = rules.first { $0.pattern.contains("\\d") }
            XCTAssertNotNil(numberRule, "\(language) should have number highlighting rule")

            let highlighted = SyntaxHighlighter.highlight(text: code, rules: rules)
            XCTAssertNotNil(highlighted)
        }
    }

    // MARK: - 高亮范围测试

    /// 测试额外高亮范围
    func testHighlightRanges() {
        let text = "Hello World Test"
        let rules: [SyntaxHighlighter.HighlightRule] = []

        // 创建一个高亮范围
        let range = text.range(of: "World")!
        let highlightColor: Color = .yellow

        let highlighted = SyntaxHighlighter.highlight(
            text: text,
            rules: rules,
            highlightRanges: [range],
            highlightColor: highlightColor
        )

        XCTAssertNotNil(highlighted)
    }

    /// 测试多个高亮范围
    func testMultipleHighlightRanges() {
        let text = "One Two Three Four"
        let rules: [SyntaxHighlighter.HighlightRule] = []

        // 创建多个高亮范围
        let range1 = text.range(of: "One")!
        let range2 = text.range(of: "Three")!
        let highlightColor: Color = .yellow

        let highlighted = SyntaxHighlighter.highlight(
            text: text,
            rules: rules,
            highlightRanges: [range1, range2],
            highlightColor: highlightColor
        )

        XCTAssertNotNil(highlighted)
    }

    // MARK: - 边界情况测试

    /// 测试空文本高亮
    func testEmptyTextHighlighting() {
        let text = ""
        let rules = CodeLanguage.swift.rules

        let highlighted = SyntaxHighlighter.highlight(text: text, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试单字符文本
    func testSingleCharacterText() {
        let text = "x"
        let rules = CodeLanguage.swift.rules

        let highlighted = SyntaxHighlighter.highlight(text: text, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试只有空白字符的文本
    func testWhitespaceOnlyText() {
        let text = "   \n\n  \t  "
        let rules = CodeLanguage.swift.rules

        let highlighted = SyntaxHighlighter.highlight(text: text, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试包含特殊字符的代码
    func testSpecialCharacters() {
        let specialTexts = [
            "let x = \"\\n\\t\\r\"",  // 转义字符
            "let regex = \"[a-z]+\"",  // 正则表达式
            "let path = \"/usr/local/bin\"",  // 路径
            "@objc func test() {}",  // 属性
            "// 注释: with special chars: @#$%"  // 注释
        ]

        for text in specialTexts {
            let rules = CodeLanguage.swift.rules
            let highlighted = SyntaxHighlighter.highlight(text: text, rules: rules)
            XCTAssertNotNil(highlighted, "Failed to highlight: \(text)")
        }
    }

    /// 测试非常长的代码行
    func testVeryLongLine() {
        let longLine = String(repeating: "let x = 1; ", count: 100)
        let rules = CodeLanguage.swift.rules

        let highlighted = SyntaxHighlighter.highlight(text: longLine, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试多行代码
    func testMultilineCode() {
        let multilineCode = """
        struct Test {
            var property: String

            func method() {
                print("Hello")
            }
        }
        """

        let rules = CodeLanguage.swift.rules
        let highlighted = SyntaxHighlighter.highlight(text: multilineCode, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试包含 Unicode 字符的代码
    func testUnicodeCharacters() {
        let unicodeTexts = [
            "let emoji = \"😀😃😄😁\"",
            "let chinese = \"你好世界\"",
            "let arabic = \"مرحبا\"",
            "let emoji = \"🎉🎊🎈\" // Party emojis"
        ]

        for text in unicodeTexts {
            let rules = CodeLanguage.swift.rules
            let highlighted = SyntaxHighlighter.highlight(text: text, rules: rules)
            XCTAssertNotNil(highlighted, "Failed to highlight unicode: \(text)")
        }
    }

    // MARK: - 语言显示名称测试

    /// 测试所有语言的显示名称
    func testLanguageDisplayNames() {
        let testCases: [(CodeLanguage, String)] = [
            (.swift, "Swift"),
            (.javascript, "Javascript"),
            (.python, "Python"),
            (.java, "Java"),
            (.cpp, "Cpp"),
            (.html, "Html"),
            (.css, "Css"),
            (.php, "Php"),
            (.plainText, "Plain Text")
        ]

        for (language, expected) in testCases {
            let displayName = language.displayName
            XCTAssertEqual(displayName, expected, "\(language) display name should be \(expected)")
        }
    }

    // MARK: - 复杂代码场景测试

    /// 测试混合语言特征（应优先匹配第一个特征）
    func testMixedLanguageFeatures() {
        // 包含多种语言特征，应该根据优先级匹配
        let mixedCode = """
        import SwiftUI  // Swift 特征
        const x = 1     // JavaScript 特征
        """

        let detected = SyntaxHighlighter.detectLanguage(mixedCode)
        // 应该检测为 Swift，因为 Swift 的检测在前
        XCTAssertEqual(detected, .swift)
    }

    /// 测试代码块高亮
    func testCodeBlockHighlighting() {
        let codeBlock = """
        func calculateSum(_ numbers: [Int]) -> Int {
            var sum = 0
            for number in numbers {
                sum += number
            }
            return sum
        }
        """

        let rules = CodeLanguage.swift.rules
        let highlighted = SyntaxHighlighter.highlight(text: codeBlock, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试嵌套结构高亮
    func testNestedStructureHighlighting() {
        let nestedCode = """
        struct Outer {
            struct Inner {
                var value: Int
            }

            func process() {
                let inner = Inner(value: 1)
            }
        }
        """

        let rules = CodeLanguage.swift.rules
        let highlighted = SyntaxHighlighter.highlight(text: nestedCode, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试性能 - 大文本高亮
    func testLargeTextHighlightingPerformance() {
        let largeCode = (0..<1000).map { i in
            "let variable\(i) = \(i)"
        }.joined(separator: "\n")

        let rules = CodeLanguage.swift.rules

        measure {
            _ = SyntaxHighlighter.highlight(text: largeCode, rules: rules)
        }
    }

    // MARK: - HTML 特定测试

    /// 测试 HTML 标签高亮
    func testHTMLTagHighlighting() {
        let html = "<div class='container'><p>Hello</p></div>"
        let rules = CodeLanguage.html.rules

        let tagRule = rules.first { $0.pattern.contains("<[^>]*>") }
        XCTAssertNotNil(tagRule, "HTML should have tag highlighting rule")

        let highlighted = SyntaxHighlighter.highlight(text: html, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试 HTML 注释高亮
    func testHTMLCommentHighlighting() {
        let htmlComment = "<!-- This is a comment -->"
        let rules = CodeLanguage.html.rules

        let commentRule = rules.first { $0.pattern.contains("<!--") }
        XCTAssertNotNil(commentRule, "HTML should have comment highlighting rule")

        let highlighted = SyntaxHighlighter.highlight(text: htmlComment, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    // MARK: - CSS 特定测试

    /// 测试 CSS 颜色高亮
    func testCSSColorHighlighting() {
        let cssColors = ".class { color: #fff; background: #000; }"
        let rules = CodeLanguage.css.rules

        let colorRule = rules.first { $0.pattern.contains("#[a-fA-F0-9]") }
        XCTAssertNotNil(colorRule, "CSS should have color highlighting rule")

        let highlighted = SyntaxHighlighter.highlight(text: cssColors, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    /// 测试 CSS 单位高亮
    func testCSSUnitHighlighting() {
        let cssUnits = ".class { width: 100px; margin: 1em; }"
        let rules = CodeLanguage.css.rules

        let unitRule = rules.first { $0.pattern.contains("px|em|rem") }
        XCTAssertNotNil(unitRule, "CSS should have unit highlighting rule")

        let highlighted = SyntaxHighlighter.highlight(text: cssUnits, rules: rules)
        XCTAssertNotNil(highlighted)
    }

    // MARK: - 实际代码示例测试

    /// 测试真实 Swift 代码高亮
    func testRealSwiftCode() {
        let realSwiftCode = """
        import SwiftUI

        struct ContentView: View {
            @State private var count = 0

            var body: some View {
                VStack {
                    Text("Count: \\(count)")
                    Button("Increment") {
                        count += 1
                    }
                }
            }
        }
        """

        let detected = SyntaxHighlighter.detectLanguage(realSwiftCode)
        XCTAssertEqual(detected, .swift)

        let highlighted = SyntaxHighlighter.highlight(
            text: realSwiftCode,
            rules: detected.rules
        )
        XCTAssertNotNil(highlighted)
    }

    /// 测试真实 JavaScript 代码高亮
    func testRealJavaScriptCode() {
        let realJSCode = """
        import React, { useState } from 'react';

        function Counter() {
            const [count, setCount] = useState(0);

            return (
                <div>
                    <p>Count: {count}</p>
                    <button onClick={() => setCount(count + 1)}>
                        Increment
                    </button>
                </div>
            );
        }

        export default Counter;
        """

        let detected = SyntaxHighlighter.detectLanguage(realJSCode)
        XCTAssertEqual(detected, .javascript)

        let highlighted = SyntaxHighlighter.highlight(
            text: realJSCode,
            rules: detected.rules
        )
        XCTAssertNotNil(highlighted)
    }

    /// 测试真实 Python 代码高亮
    func testRealPythonCode() {
        let realPythonCode = """
        from typing import List

        def process_data(items: List[int]) -> int:
            '''Process a list of items and return the sum.'''
            total = 0
            for item in items:
                if item > 0:
                    total += item
            return total

        # Main execution
        if __name__ == "__main__":
            result = process_data([1, 2, 3, 4, 5])
            print(f"Result: {result}")
        """

        let detected = SyntaxHighlighter.detectLanguage(realPythonCode)
        XCTAssertEqual(detected, .python)

        let highlighted = SyntaxHighlighter.highlight(
            text: realPythonCode,
            rules: detected.rules
        )
        XCTAssertNotNil(highlighted)
    }
}
