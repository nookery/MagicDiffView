#if DEBUG
import SwiftUI

/// 指定语言示例演示
struct LanguageSpecificDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "// 旧版本 JavaScript 代码\nfunction calculateTotal(items) {\n  var total = 0;\n  for (var i = 0; i < items.length; i++) {\n    total += items[i].price;\n  }\n  return total;\n}",
            newText: "// 新版本 JavaScript 代码\nfunction calculateTotal(items) {\n  // 使用 reduce 方法计算总和\n  const total = items.reduce((sum, item) => {\n    return sum + item.price;\n  }, 0);\n  \n  return total;\n}"
        )
    }
}

// MARK: - Preview

#Preview("指定语言") {
    LanguageSpecificDiffView()
        .frame(height: 600)
}
#endif
