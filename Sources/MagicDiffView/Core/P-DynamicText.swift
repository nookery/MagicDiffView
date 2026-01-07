#if DEBUG
import SwiftUI

/// 动态文本变化演示视图
/// 用于测试 MagicDiffView 在父视图状态变化时的重新创建行为
struct DynamicTextPreview: View {
    @State private var oldText = ""
    @State private var newText = ""

    var body: some View {
        VStack(spacing: 20) {
            // 状态显示
            statusDisplayView

            // MagicDiffView
            MagicDiffView(
                oldText: oldText,
                newText: newText,
                verbose: true
            )
        }
        .padding()
        .onAppear(perform: handleOnAppear)
    }
}

// MARK: - View
extension DynamicTextPreview {
    /// 状态显示视图
    private var statusDisplayView: some View {
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
    }
}

// MARK: - Event Handler
extension DynamicTextPreview {
    /// 处理视图出现事件
    func handleOnAppear() {
        // 延迟 1 秒后设置 Swift 代码
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                updateDemoContent()
            }
        }
    }
}

// MARK: - Private Helpers
extension DynamicTextPreview {
    /// 更新演示内容
    private func updateDemoContent() {
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

// MARK: - Preview

#Preview("动态文本变化") {
    DynamicTextPreview()
        .frame(height: 600)
}
#endif
