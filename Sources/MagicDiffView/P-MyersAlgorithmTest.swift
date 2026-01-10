#if DEBUG
import SwiftUI

/// Myers 算法测试视图
struct MyersAlgorithmTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Myers 算法性能测试")
                .font(.largeTitle)
                .padding()

            // 测试 1: 简单的文本比较
            GroupBox(label: Text("测试 1: 简单文本比较")) {
                MagicDiffView(
                    oldText: simpleOldText,
                    newText: simpleNewText,
                    algorithmVersion: .myers  // 使用 Myers 算法
                )
                .frame(height: 200)
            }

            // 测试 2: 大文件性能测试
            GroupBox(label: Text("测试 2: 大文件性能（1000 行）")) {
                MagicDiffView(
                    oldText: largeOldText,
                    newText: largeNewText,
                    algorithmVersion: .myers  // 使用 Myers 算法
                )
                .frame(height: 300)
            }

            // 测试 3: 算法对比
            GroupBox(label: Text("测试 3: 算法版本对比")) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("Legacy 算法")
                            .font(.headline)
                        MagicDiffView(
                            oldText: testOldText,
                            newText: testNewText,
                            algorithmVersion: .legacy
                        )
                        .frame(width: 300, height: 150)
                    }

                    VStack(alignment: .leading) {
                        Text("Myers 算法")
                            .font(.headline)
                        MagicDiffView(
                            oldText: testOldText,
                            newText: testNewText,
                            algorithmVersion: .myers
                        )
                        .frame(width: 300, height: 150)
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Test Data

    private var simpleOldText: String {
        """
        Hello World
        This is line 2
        This is line 3
        """
    }

    private var simpleNewText: String {
        """
        Hello Swift
        This is line 2
        This is modified line 3
        This is line 4
        """
    }

    private var largeOldText: String {
        var lines: [String] = []
        for i in 1...1000 {
            lines.append("Line \(i): Original content")
        }
        return lines.joined(separator: "\n")
    }

    private var largeNewText: String {
        var lines: [String] = []
        for i in 1...1000 {
            if i % 100 == 0 {
                lines.append("Line \(i): Modified content")
            } else {
                lines.append("Line \(i): Original content")
            }
        }
        return lines.joined(separator: "\n")
    }

    private var testOldText: String {
        """
        struct User {
            let id: Int
            let name: String
            let email: String

            func validate() -> Bool {
                return !name.isEmpty
            }
        }
        """
    }

    private var testNewText: String {
        """
        struct User {
            let id: Int
            let name: String
            let email: String
            let age: Int?

            func validate() -> Bool {
                return !name.isEmpty && email.contains("@")
            }
        }
        """
    }
}

// MARK: - Preview

#Preview("Myers 算法测试") {
    MyersAlgorithmTestView()
}
#endif
