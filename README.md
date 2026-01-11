# MagicDiffView

A powerful SwiftUI view component for comparing and displaying text differences with unified diff support.

> 📖 [中文文档](README_zh-CN.md)

## Features

- **Text Diff Comparison**: Compare two text strings and highlight differences
- **Unified Diff Parser**: Parse unified diff format from Git and other tools
- **Syntax Highlighting**: Support for multiple programming languages
- **Collapsible Blocks**: Automatically collapse unchanged sections
- **Multiple View Modes**: Unified diff, split view, original, and modified text
- **Line Numbers**: Accurate line number mapping
- **Cross-platform**: Supports macOS and iOS

## Installation

### Swift Package Manager

Add this package to your project via Xcode:

1. In Xcode, go to **File > Swift Packages > Add Package Dependency**
2. Enter the repository URL
3. Select the **main** branch
4. Click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/your-username/MagicDiffView.git",
        branch: "main"
    )
]
```

## Quick Start

### Basic Usage - Compare Two Texts

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

### Parse Git Diff

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

### Compute Diff from Arrays

```swift
let oldLines = ["Line 1", "Line 2 old", "Line 3"]
let newLines = ["Line 1", "Line 2 new", "Line 3"]

let diffLines = MyersDiffAlgorithm.computeDiff(
    oldLines: oldLines,
    newLines: newLines
)
```

## API Reference

### `MagicDiffView`

```swift
// Initialize with text
init(oldText: String, newText: String)

// Initialize with pre-computed diff lines
init(diffLines: [DiffLine])
```

### `MyersDiffAlgorithm`

```swift
// Compute diff from two text arrays
static func computeDiff(
    oldLines: [String],
    newLines: [String]
) -> [DiffLine]

// Parse unified diff format (throws on error)
static func parseUnifiedDiff(
    _ unifiedDiffText: String
) throws -> [DiffLine]

// Parse unified diff format (returns empty array on error)
static func parseUnifiedDiffSafely(
    _ unifiedDiffText: String
) -> [DiffLine]
```

## Supported Formats

### Standard Unified Diff

```diff
@@ -1,3 +1,3 @@
 Line 1
-Line 2 old
+Line 2 new
 Line 3
```

### Git Format

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

## Requirements

- iOS 17.0+ or macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
