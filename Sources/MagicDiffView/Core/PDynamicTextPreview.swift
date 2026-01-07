import SwiftUI

/// 动态文本变化演示视图
/// 用于测试 MagicDiffView 在父视图状态变化时的重新创建行为
struct DynamicTextPreview: View {
    @State private var oldText = ""
    @State private var newText = ""

    var body: some View {
        VStack(spacing: 20) {
            // 状态显示
            VStack(alignment: .leading, spacing: 8) {
                Text("当前状态:")
                    .font(.headline)
                Text("oldText: \(oldText.isEmpty ? "空" : "\(oldText.count) 字符")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("newText: \(newText.isEmpty ? "空" : "\(newText.count) 字符")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

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
                }
            }
        }
    }
}

#Preview("动态文本变化") {
    DynamicTextPreview()
}
