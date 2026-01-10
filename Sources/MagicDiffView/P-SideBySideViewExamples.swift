#if DEBUG
import SwiftUI

/// 并排视图示例
struct SideBySideViewExamples: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("并排视图示例")
                .font(.largeTitle)
                .padding()

            TabView {
                // 示例 1: 代码变更
                VStack {
                    Text("示例 1: Swift 代码变更")
                        .font(.headline)
                        .padding()

                    MagicDiffView(
                        oldText: oldSwiftCode,
                        newText: newSwiftCode
                    )
                }
                .tabItem {
                    Label("代码变更", systemImage: "chevron.left.forwardslash.chevron.right")
                }

                // 示例 2: 文本修改
                VStack {
                    Text("示例 2: 文本修改")
                        .font(.headline)
                        .padding()

                    MagicDiffView(
                        oldText: oldText,
                        newText: newText
                    )
                }
                .tabItem {
                    Label("文本修改", systemImage: "doc.text")
                }

                // 示例 3: 大型变更
                VStack {
                    Text("示例 3: 大型变更")
                        .font(.headline)
                        .padding()

                    MagicDiffView(
                        oldText: largeOldCode,
                        newText: largeNewCode
                    )
                }
                .tabItem {
                    Label("大型变更", systemImage: "doc.on.doc")
                }
            }
        }
        .frame(height: 600)
    }

    // MARK: - Test Data

    private var oldSwiftCode: String {
        """
        struct User {
            let id: Int
            let name: String
            let email: String

            init(id: Int, name: String, email: String) {
                self.id = id
                self.name = name
                self.email = email
            }

            func validate() -> Bool {
                return !name.isEmpty
            }
        }
        """
    }

    private var newSwiftCode: String {
        """
        struct User {
            let id: Int
            let name: String
            let email: String
            let age: Int?
            let avatarURL: URL?

            init(
                id: Int,
                name: String,
                email: String,
                age: Int? = nil,
                avatarURL: URL? = nil
            ) {
                self.id = id
                self.name = name
                self.email = email
                self.age = age
                self.avatarURL = avatarURL
            }

            func validate() -> Bool {
                return !name.isEmpty && email.contains("@")
            }

            func displayName() -> String {
                name.isEmpty ? "Unknown" : name
            }
        }
        """
    }

    private var oldText: String {
        [
            "MagicDiffView 是一个强大的 SwiftUI 差异视图组件。",
            "",
            "它提供了以下特性：",
            "- 语法高亮",
            "- 代码折叠",
            "- 多主题支持",
            "- 性能优化",
            "",
            "适用于代码审查、文档比较等场景。"
        ].joined(separator: "\n")
    }

    private var newText: String {
        [
            "MagicDiffView 是一个强大的 SwiftUI 差异视图组件。",
            "",
            "它提供了以下特性：",
            "- 语法高亮",
            "- 代码折叠",
            "- 多主题支持",
            "- 性能优化",
            "- 并排视图对比",
            "- Myers diff 算法",
            "",
            "适用于代码审查、文档比较、版本对比等场景。",
            "",
            "让代码差异一目了然！"
        ].joined(separator: "\n")
    }

    private var largeOldCode: String {
        """
        class DataProcessor {
            private let data: [String]

            func processAll() -> [String] {
                return data.map { $0.uppercased() }
            }
        }
        """
    }

    private var largeNewCode: String {
        """
        class DataProcessor {
            private let data: [String]
            private let options: ProcessingOptions

            func processAll() -> [String] {
                return data.map { process($0) }
            }

            private func process(_ input: String) -> String {
                return options.trimWhitespace ?
                       input.trimmingCharacters(in: .whitespaces).uppercased() :
                       input.uppercased()
            }
        }
        """
    }
}

// MARK: - Preview

#Preview("并排视图示例") {
    SideBySideViewExamples()
}
#endif
