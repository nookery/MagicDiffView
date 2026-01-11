# MagicDiffView

一个功能强大的 SwiftUI 视图组件，用于比较和显示文本差异，采用高性能差异算法并支持 unified diff 格式解析。

## 功能特性

- **高性能差异算法**：优化的 Myers O(ND) 算法，高效比较文本差异
- **Unified Diff 解析**：原生支持 unified diff 格式解析，与 Git 兼容
- **语法高亮**：支持多种编程语言的语法高亮
- **可折叠块**：自动折叠未更改的部分以提高可读性
- **多种视图模式**：可在 unified diff、分屏视图、原始文本和修改文本之间切换
- **复制到剪贴板**：轻松复制差异内容
- **行号显示**：精确的行号映射
- **跨平台支持**：同时支持 macOS 和 iOS

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

### 基础用法

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
    let gitDiffOutput: String

    var body: some View {
        // 解析 unified diff 格式
        let diffLines = MyersDiffAlgorithm.parseUnifiedDiffSafely(gitDiffOutput)

        return MagicDiffView(diffLines: diffLines)
    }
}
```

### 高级用法：自定义差异计算

```swift
let oldLines = ["Line 1", "Line 2 old"]
let newLines = ["Line 1", "Line 2 new", "Line 3"]

// 使用 Myers 算法计算最优差异
let diffLines = MyersDiffAlgorithm.computeDiff(
    oldLines: oldLines,
    newLines: newLines
)
```

## API 概览

### `MagicDiffView` 组件

```swift
// 从文本计算差异
init(
    oldText: String,
    newText: String,
    showLineNumbers: Bool = true,
    contextLines: Int = 3
)

// 从已有的差异行数组创建
init(diffLines: [DiffLine])
```

### `MyersDiffAlgorithm` 差异算法

```swift
// 从两个文本数组计算差异
static func computeDiff(
    oldLines: [String],
    newLines: [String]
) -> [DiffLine]

// 解析 unified diff 格式（抛出异常）
static func parseUnifiedDiff(
    _ unifiedDiffText: String
) throws -> [DiffLine]

// 解析 unified diff 格式（安全版本）
static func parseUnifiedDiffSafely(
    _ unifiedDiffText: String
) -> [DiffLine]
```

## 支持的差异格式

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
+    let age: Int
 }
```

## 性能特点

- **小文件**（<100 行）：快速路径优化，即时结果
- **大文件**（1000+ 行）：O(ND) 算法，O(N) 空间复杂度
- **超大文件**（10000+ 行）：内存高效的滚动数组优化

## 系统要求

- iOS 17.0+ 或 macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## 技术细节

### 算法实现

- **核心算法**：基于 Eugene Myers 的经典论文《An O(ND) Difference Algorithm and Its Variations》(1986)
- **时间复杂度**：O((m + n) × D)，其中 m、n 为行数，D 为编辑距离
- **空间复杂度**：
  - 小文件：O(m × n)
  - 大文件（>500 行）：O(min(m, n)) 使用滚动数组优化

### 差异类型

```swift
enum DiffLineType {
    case unchanged    // 未更改的行
    case added        // 新增的行
    case removed      // 删除的行
    case modified     // 修改的行（同时有删除和新增）
}
```

## 使用场景

### 场景 1：版本控制集成

```swift
struct CommitDetailView: View {
    let commit: Commit

    var body: some View {
        let diffLines = MyersDiffAlgorithm.parseUnifiedDiffSafely(commit.diff)
        MagicDiffView(diffLines: diffLines)
    }
}
```

### 场景 2：代码审查工具

```swift
struct PullRequestView: View {
    let prDiff: String

    var body: some View {
        let diffLines = MyersDiffAlgorithm.parseUnifiedDiffSafely(prDiff)
        LazyVStack {
            ForEach(diffLines.indices, id: \.self) { index in
                DiffLineRow(line: diffLines[index])
            }
        }
    }
}
```

### 场景 3：文本对比工具

```swift
struct TextCompareView: View {
    @State private var oldText = ""
    @State private var newText = ""

    var body: some View {
        VStack {
            MagicDiffView(oldText: oldText, newText: newText)
        }
    }
}
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献指南

欢迎贡献代码！请随时提交 Pull Request。

## 致谢

- 基于 Eugene Myers 的经典论文《An O(ND) Difference Algorithm and Its Variations》(1986)
- 灵感来源于 GitHub Desktop 的差异视图实现
