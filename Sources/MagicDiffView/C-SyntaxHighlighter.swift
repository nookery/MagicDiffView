import SwiftUI
import OSLog

/// String 扩展，用于正则表达式匹配
extension String {
    /// 检查字符串是否匹配给定的正则表达式
    func matches(regex: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else {
            return false
        }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

/// 语法高亮器
/// 提供基本的代码语法高亮功能
public struct SyntaxHighlighter {
    static let emoji = "📝"

    /// 语法高亮规则
    struct HighlightRule {
        let pattern: String
        let color: Color

        static let swift: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(class|struct|enum|protocol|extension|func|var|let|if|else|guard|switch|case|default|for|while|do|try|catch|throw|throws|rethrows|return|break|continue|where|in|init|deinit|self|super|true|false|nil|async|await|some|any)\\b", color: .purple),

            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),

            // 数字
            .init(pattern: "\\b([0-9]+\\.?[0-9]*|\\.[0-9]+)\\b", color: .blue),

            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),

            // 类型名（首字母大写）
            .init(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b", color: .orange),

            // 属性和函数调用
            .init(pattern: "\\.[a-zA-Z_][a-zA-Z0-9_]*", color: .teal),

            // 特殊字符
            .init(pattern: "@[a-zA-Z_][a-zA-Z0-9_]*", color: .blue)
        ]

        static let javascript: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(const|let|var|function|class|extends|new|if|else|for|while|do|switch|case|break|continue|return|try|catch|finally|throw|async|await|import|export|default|null|undefined|true|false|this|super)\\b", color: .purple),

            // 字符串
            .init(pattern: "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|`[^`\\\\]*(?:\\\\.[^`\\\\]*)*`", color: .red),

            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+\\b", color: .blue),

            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),

            // 函数调用
            .init(pattern: "\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", color: .teal),

            // 对象属性
            .init(pattern: "\\.[a-zA-Z_][a-zA-Z0-9_]*", color: .teal)
        ]

        static let python: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(def|class|if|else|elif|for|while|try|except|finally|with|as|import|from|return|yield|break|continue|pass|raise|True|False|None|and|or|not|is|in|lambda|nonlocal|global|del|async|await)\\b", color: .purple),

            // 字符串
            .init(pattern: "'''[\\s\\S]*?'''|\"\"\"[\\s\\S]*?\"\"\"|'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),

            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+\\b", color: .blue),

            // 注释
            .init(pattern: "#.*$", color: .secondary),

            // 装饰器
            .init(pattern: "@[a-zA-Z_][a-zA-Z0-9_]*", color: .blue),

            // 函数调用
            .init(pattern: "\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", color: .teal)
        ]

        static let java: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(public|private|protected|class|interface|abstract|extends|implements|import|package|new|return|if|else|for|while|do|switch|case|break|continue|try|catch|finally|throw|throws|static|final|void|int|long|float|double|boolean|char|byte|short|enum|assert|synchronized|volatile|transient|native|strictfp|instanceof|super|this|null|true|false)\\b", color: .purple),

            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),

            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+[LlFfDd]?\\b", color: .blue),

            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),

            // 类名
            .init(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b", color: .orange),

            // 注解
            .init(pattern: "@[a-zA-Z_][a-zA-Z0-9_]*", color: .blue)
        ]

        static let cpp: [HighlightRule] = [
            // 关键字
            .init(pattern: "\\b(auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|class|namespace|template|public|private|protected|virtual|inline|explicit|friend|using|try|catch|throw|new|delete|this|operator|bool|true|false|nullptr)\\b", color: .purple),

            // 预处理指令
            .init(pattern: "#[a-zA-Z]+\\b", color: .blue),

            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", color: .red),

            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+[UuLlFf]*\\b", color: .blue),

            // 注释
            .init(pattern: "//.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),

            // 类名
            .init(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b", color: .orange)
        ]

        static let html: [HighlightRule] = [
            // 标签
            .init(pattern: "</?[a-zA-Z][^>]*>", color: .purple),

            // 属性
            .init(pattern: "\\b[a-zA-Z-]+(?=\\s*=\\s*[\"'])", color: .teal),

            // 字符串
            .init(pattern: "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'", color: .red),

            // 注释
            .init(pattern: "<!--[\\s\\S]*?-->", color: .secondary),

            // DOCTYPE
            .init(pattern: "<!DOCTYPE[^>]*>", color: .blue)
        ]

        static let css: [HighlightRule] = [
            // 选择器
            .init(pattern: "[.#]?[a-zA-Z][a-zA-Z0-9_-]*(?=[\\s{,])", color: .purple),

            // 属性
            .init(pattern: "[a-zA-Z-]+(?=\\s*:)", color: .teal),

            // 值
            .init(pattern: ":\\s*[^;\\n]+", color: .blue),

            // 注释
            .init(pattern: "/\\*[\\s\\S]*?\\*/", color: .secondary),

            // 单位
            .init(pattern: "\\b\\d+(?:px|em|rem|%|pt|vh|vw)\\b", color: .orange),

            // 颜色
            .init(pattern: "#[a-fA-F0-9]{3,6}\\b", color: .red)
        ]

        static let php: [HighlightRule] = [
            // PHP标签
            .init(pattern: "<?php\\b|\\?>", color: .purple),

            // 关键字
            .init(pattern: "\\b(abstract|and|array|as|break|callable|case|catch|class|clone|const|continue|declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|final|finally|fn|for|foreach|function|global|goto|if|implements|include|include_once|instanceof|insteadof|interface|isset|list|match|namespace|new|or|print|private|protected|public|require|require_once|return|static|switch|throw|trait|try|unset|use|var|while|yield|__CLASS__|__DIR__|__FILE__|__FUNCTION__|__LINE__|__METHOD__|__NAMESPACE__|__TRAIT__)\\b", color: .purple),

            // 字符串
            .init(pattern: "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|<<<['\"](\\w+)['\"](.|\\n)*?\\1;?", color: .red),

            // 变量
            .init(pattern: "\\$[a-zA-Z_][a-zA-Z0-9_]*", color: .teal),

            // 注释
            .init(pattern: "//.*$|#.*$|/\\*[\\s\\S]*?\\*/", color: .secondary),

            // 数字
            .init(pattern: "\\b\\d*\\.?\\d+\\b", color: .blue)
        ]
    }

    /// 对文本应用语法高亮
    /// - Parameters:
    ///   - text: 要高亮的文本
    ///   - rules: 高亮规则数组
    ///   - highlightRanges: 需要额外高亮的范围（如差异部分）
    ///   - highlightColor: 额外高亮的背景颜色
    ///   - verbose: 是否输出详细日志
    /// - Returns: 高亮后的文本视图
    static func highlight(text: String, rules: [HighlightRule], highlightRanges: [Range<String.Index>]? = nil, highlightColor: Color? = nil, verbose: Bool = false) -> Text {
        var attributedString = AttributedString(text)
        let nsRange = NSRange(location: 0, length: text.utf16.count)

        for rule in rules {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: []) else {
                continue
            }

            let matches = regex.matches(in: text, options: [], range: nsRange)
            for match in matches {
                guard let range = Range(match.range, in: text) else { continue }
                let color = rule.color
                if let attrRange = Range(range, in: attributedString) {
                    attributedString[attrRange].foregroundColor = color
                }
            }
        }

        // 应用额外的高亮（如差异部分）
        if let ranges = highlightRanges, let color = highlightColor {
            for range in ranges {
                if let attrRange = Range(range, in: attributedString) {
                    attributedString[attrRange].backgroundColor = color
                }
            }
        }

        return Text(attributedString)
    }

    /// 检测代码语言类型
    /// 按照特征独特性从高到低的顺序检测：
    /// 1. PHP (<?php 标签)
    /// 2. C++ (#include)
    /// 3. HTML (<!DOCTYPE, <html>, <div>, <head>, <body>, </>)
    /// 4. CSS ({, }, #, . 选择器)
    /// 5. Java (package, import java., @Override, public class)
    /// 6. Python (def, from ... import, class :, #注释)
    /// 7. Swift (struct: View, @State, func, import + var/let)
    /// 8. JavaScript (const/let/var, =>, function, import ... from)
    /// - Parameters:
    ///   - text: 要检测的代码文本
    ///   - verbose: 是否启用详细日志，默认为 false
    /// - Returns: 推测的语言类型
    public static func detectLanguage(_ text: String, verbose: Bool = false) -> CodeLanguage {
        if verbose {
            os_log("🔍 开始语言检测，文本长度: \(text.count)")
            let preview = String(text.prefix(200))
            os_log("🔍 文本预览: \(preview)")
        }

        let lines = text.components(separatedBy: .newlines)
        let firstLines = lines.prefix(5)

        // 1. PHP特征 - 最独特的 <?php 标签
        if firstLines.contains(where: { $0.hasPrefix("<?php") }) ||
           text.contains("<?php") ||
           (text.contains("$") && (text.contains("function ") || text.contains("class "))) {
            if verbose {
                os_log("👓 检测到 PHP 代码")
            }
            return .php
        }

        // 2. C++特征 - 独特的 #include
        if firstLines.contains(where: { $0.hasPrefix("#include") }) ||
           text.contains("using namespace") || text.contains("std::") {
            if verbose {
                os_log("👓 检测到 C++ 代码")
            }
            return .cpp
        }

        // 3. HTML特征 - 独特的标签（但不包括 JSX/React）
        if firstLines.contains(where: { $0.hasPrefix("<!DOCTYPE") || $0.hasPrefix("<html>") }) ||
           (text.contains("<!DOCTYPE") && !text.contains("import")) ||
           (text.contains("</div>") && !text.contains("import")) ||
           (text.contains("<head>") && !text.contains("import")) ||
           (text.contains("<body>") && !text.contains("import")) {
            if verbose {
                os_log("👓 检测到 HTML 代码")
            }
            return .html
        }

        // 4. CSS特征 - {, }, #, . 选择器
        // 必须在大多数语言之前检测，但需要排除编程语言
        if text.contains("{") && text.contains("}") {
            // 检查是否包含 CSS 特有的选择器或属性模式
            let hasCSSPatterns = lines.contains { line in
                // CSS 选择器模式：#id {, .class {
                line.matches(regex: "^[#\\.][a-zA-Z_-]+\\s*\\{") ||
                line.matches(regex: "^[#\\.][a-zA-Z]") ||
                // CSS 属性模式：property: value;
                line.contains(":") && (line.contains(";") || line.contains("px") || line.contains("em") || line.contains("rem") || line.contains("%"))
            }
            // 排除编程语言（它们也包含 {}）
            let hasNoProgrammingLanguage = !text.contains("function") && !text.contains("def ") &&
                                            !text.contains("import") && !text.contains("return") &&
                                            !text.contains("@") && !text.contains("package")

            if hasCSSPatterns && hasNoProgrammingLanguage {
                if verbose {
                    os_log("👓 检测到 CSS 代码")
                }
                return .css
            }
        }

        // 5. Java特征 - package, import java., @Override, public class
        if firstLines.contains(where: { $0.hasPrefix("package ") }) ||
           text.contains("import java.") ||
           text.contains("@Override") ||
           text.contains("public class") ||
           text.contains("public static void main") {
            if verbose {
                os_log("👓 检测到 Java 代码")
            }
            return .java
        }

        // 6. Python特征 - def, from ... import, class :, #注释
        if firstLines.contains(where: { $0.hasPrefix("def ") || $0.hasPrefix("from ") }) ||
           lines.contains(where: { $0.hasPrefix("class ") && $0.contains(":") }) ||  // Python 的 class 后面有冒号
           text.contains(":#") || text.contains(": #") ||
           text.contains("#!") && text.contains("python") {
            if verbose {
                os_log("👓 检测到 Python 代码")
            }
            return .python
        }

        // 7. Swift特征 - struct: View, @State, func, import SwiftUI/Foundation/UIKit/Combine
        // 检测 Swift 的独特特征：属性包装器、Swift 特定的 struct 用法、Swift import 语句
        if text.contains("@State") || text.contains("@Published") || text.contains("@Observable") ||
           (text.contains("struct") && (text.contains(": View") || text.contains(": UIViewController"))) ||
           (text.contains("func ") && !text.contains("function ")) ||
           // Swift 特定的 import 语句（SwiftUI, Foundation, UIKit, Combine）
           text.contains("import SwiftUI") || text.contains("import Foundation") ||
           firstLines.contains(where: { line in
               line.hasPrefix("import ") && !line.contains(" from ") &&
               (line.contains("UIKit") || line.contains("Combine"))
           }) {
            if verbose {
                os_log("👓 检测到 Swift 代码")
            }
            return .swift
        }

        // 8. JavaScript特征 - const/let/var, =>, function, import ... from, JSX
        if firstLines.contains(where: { $0.hasPrefix("const ") || $0.hasPrefix("var ") }) ||  // let 可能在 Swift 中也出现
           text.contains("function ") || text.contains("=>") ||
           text.contains("require(") ||
           (text.contains("import ") && text.contains(" from ")) ||
           (text.contains("<div>") || text.contains("<script>")) && text.contains("import") {
            if verbose {
                os_log("👓 检测到 JavaScript 代码")
            }
            return .javascript
        }

        if verbose {
            os_log("❌ 未检测到特定语言，返回 plainText")
        }

        return .plainText
    }

    /// 测试语言检测功能
    static func testLanguageDetection() {
        let testCases = [
            ("Swift代码", "import SwiftUI\n\nstruct ContentView: View {\n    @State private var count = 0\n    \n    var body: some View {\n        Text(\"Hello\")\n    }\n}"),
            ("JavaScript代码", "const items = [];\nfunction calculateTotal() {\n    return items.reduce((sum, item) => sum + item.price, 0);\n}"),
            ("Python代码", "def hello_world():\n    print('Hello, World!')\n    return True"),
            ("纯文本", "这是一段普通的文本\n没有任何编程语言特征")
        ]

        for (name, code) in testCases {
            let detected = detectLanguage(code, verbose: true)
            os_log("🧪 测试 \(name): 检测结果 = \(detected.rawValue)")
        }
    }
}

/// 支持的代码语言
public enum CodeLanguage: String, CaseIterable {
    case swift
    case javascript
    case python
    case java
    case cpp
    case html
    case css
    case php
    case plainText

    /// 获取语言对应的高亮规则
    var rules: [SyntaxHighlighter.HighlightRule] {
        switch self {
        case .swift:
            return SyntaxHighlighter.HighlightRule.swift
        case .javascript:
            return SyntaxHighlighter.HighlightRule.javascript
        case .python:
            return SyntaxHighlighter.HighlightRule.python
        case .java:
            return SyntaxHighlighter.HighlightRule.java
        case .cpp:
            return SyntaxHighlighter.HighlightRule.cpp
        case .html:
            return SyntaxHighlighter.HighlightRule.html
        case .css:
            return SyntaxHighlighter.HighlightRule.css
        case .php:
            return SyntaxHighlighter.HighlightRule.php
        case .plainText:
            return []
        }
    }

    /// 获取语言的显示名称
    var displayName: String {
        switch self {
        case .plainText:
            return "Plain Text"
        default:
            return rawValue.capitalized
        }
    }
}

