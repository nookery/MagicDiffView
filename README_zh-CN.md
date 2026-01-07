# MagicDiffView

一个用于比较和显示文本差异的 SwiftUI 视图组件，类似于 GitHub Desktop 的差异视图。

## 功能特性

- **文本差异比较**：比较两个文本字符串并高亮显示差异
- **语法高亮**：支持 Swift 和 JavaScript 语法高亮
- **可折叠块**：自动折叠未更改的部分以提高可读性
- **多种视图模式**：可在差异视图、原始文本和修改文本之间切换
- **复制到剪贴板**：轻松复制差异内容
- **行号显示**：可选的行号显示
- **跨平台支持**：同时支持 macOS 和 iOS

## 使用方法

```swift
import SwiftUI
import MagicDiffView

struct ContentView: View {
    var body: some View {
        MagicDiffView(
            oldText: "Hello World\nThis is line 2",
            newText: "Hello Swift\nThis is line 2\nNew line 3"
        )
    }
}
```

## 安装方式

### Swift Package Manager

在您的 `Package.swift` 文件中添加以下依赖：

```swift
dependencies: [
    .package(url: "https://github.com/your-username/MagicDiffView.git", from: "1.0.0")
]
```

或者直接在 Xcode 中添加：
1. 在 Xcode 中打开您的项目
2. 选择 File > Swift Packages > Add Package Dependency
3. 输入仓库地址：`https://github.com/your-username/MagicDiffView.git`

## 系统要求

- iOS 17.0+ 或 macOS 14.0+
- Swift 5.9+

## 许可证

本包采用 MIT 许可证。详情请见 LICENSE 文件。
