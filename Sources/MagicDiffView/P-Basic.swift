#if DEBUG
import SwiftUI

/// 基础差异视图演示
struct BasicDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "Hello World\nLine 2\nLine 3",
            newText: "Hello Swift\nLine 2\nLine 3 Modified"
        )
    }
}

// MARK: - Preview

#Preview("基础差异") {
    BasicDiffView()
        .frame(height: 400)
}
#endif
