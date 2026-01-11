# MagicDiffView

一个功能强大的 SwiftUI 视图组件，用于比较和显示文本差异，支持 unified diff 格式。

## 功能特性

- **文本差异比较**：比较两个文本字符串并高亮显示差异
- **Unified Diff 解析**：解析 Git 等工具的 unified diff 格式
- **语法高亮**：支持多种编程语言的语法高亮
- **可折叠块**：自动折叠未更改的部分
- **多种视图模式**：Unified diff、分屏、原始文本、修改文本
- **行号显示**：精确的行号映射
- **跨平台支持**：支持 macOS 和 iOS

## 安装方式

### Swift Package Manager

通过 Xcode 添加此包：

1. 在 Xcode 中，选择 **File > Swift Packages > Add Package Dependency**
2. 输入仓库 URL
3. 选择 **main** 分支
4. 点击 **Add Package**

或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(
        url: "https://github.com/your-username/MagicDiffView.git",
        branch: "main"
    )
]
```

## 快速开始

### 基础用法 - 比较两个文本

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

### 解析 Git Diff

```swift
import MagicDiffView

struct GitDiffView: View {
    let gitDiffOutput: String = """
    diff --git a/file.txt b/file.txt
    @@ -1,3 +1,3 @@
     Line 1
    -Line 2 old
    +Line 2 new
     Line 3
    """

    var body: some View {
        let diffLines = MyersDiffAlgorithm.parseUnifiedDiffSafely(gitDiffOutput)
        return MagicDiffView(diffLines: diffLines)
    }
}
```

### 从数组计算差异

```swift
let oldLines = ["Line 1", "Line 2 old", "Line 3"]
let newLines = ["Line 1", "Line 2 new", "Line 3"]

let diffLines = MyersDiffAlgorithm.computeDiff(
    oldLines: oldLines,
    newLines: newLines
)
```

## API 参考

### `MagicDiffView`

```swift
// 从文本初始化
init(oldText: String, newText: String)

// 从预计算的差异行初始化
init(diffLines: [DiffLine])
```

### `MyersDiffAlgorithm`

```swift
// 从两个文本数组计算差异
static func computeDiff(
    oldLines: [String],
    newLines: [String]
) -> [DiffLine]

// 解析 unified diff 格式（错误时抛出异常）
static func parseUnifiedDiff(
    _ unifiedDiffText: String
) throws -> [DiffLine]

// 解析 unified diff 格式（错误时返回空数组）
static func parseUnifiedDiffSafely(
    _ unifiedDiffText: String
) -> [DiffLine]
```

## 支持的格式

### 标准 Unified Diff

```diff
@@ -1,3 +1,3 @@
 Line 1
-Line 2 old
+Line 2 new
 Line 3
```

### Git 格式

```diff
diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -1,5 +1,6 @@
 import Foundation
 class User {
-    let name: String
+    let name: String?
 }
```

## 系统要求

- iOS 17.0+ 或 macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献指南

欢迎贡献代码！请随时提交 Pull Request。
