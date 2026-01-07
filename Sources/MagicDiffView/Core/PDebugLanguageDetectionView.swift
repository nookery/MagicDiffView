import SwiftUI

/// 调试语言检测视图
struct DebugLanguageDetectionView: View {
    @State private var oldText = ""
    @State private var newText = ""
    @State private var detectedLanguage: CodeLanguage = .plainText

    var body: some View {
        VStack(spacing: 20) {
            // 状态显示
            VStack(alignment: .leading, spacing: 8) {
                Text("调试信息:")
                    .font(.headline)
                Text("oldText: \(oldText.isEmpty ? "空" : "\(oldText.count) 字符")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("newText: \(newText.isEmpty ? "空" : "\(newText.count) 字符")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("检测到的语言: \(detectedLanguage.rawValue)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // 手动检测按钮
            Button("手动检测语言") {
                let textToDetect = newText.isEmpty ? oldText : newText
                detectedLanguage = SyntaxHighlighter.detectLanguage(textToDetect, verbose: true)
            }
            .buttonStyle(.borderedProminent)

            // MagicDiffView
            MagicDiffView(
                oldText: oldText,
                newText: newText,
                verbose: true
            )
        }
        .padding()
        .onAppear {
            // 延迟 1 秒后设置 Swift 代码
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    oldText = """
                    struct OldView: View {
                        var body: some View {
                            Text("Hello")
                        }
                    }
                    """

                    newText = """
                    struct NewView: View {
                        @State private var message = "Hello, World!"

                        var body: some View {
                            VStack {
                                Text(message)
                                    .font(.title)
                                Button("Update") {
                                    message = "Updated!"
                                }
                            }
                            .padding()
                        }
                    }
                    """

                    // 手动检测一次
                    let textToDetect = newText.isEmpty ? oldText : newText
                    detectedLanguage = SyntaxHighlighter.detectLanguage(textToDetect, verbose: true)
                }
            }
        }
    }
}

#Preview("调试语言检测") {
    DebugLanguageDetectionView()
}
