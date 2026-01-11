# MagicDiffView

A powerful SwiftUI view component for comparing and displaying text differences, featuring a high-performance diff algorithm with unified diff support.

> 📖 [中文文档](README_zh-CN.md)

## Features

- **High-Performance Diff Algorithm**: Optimized Myers O(ND) algorithm for efficient text comparison
- **Unified Diff Parser**: Native support for parsing unified diff format (Git-compatible)
- **Syntax Highlighting**: Support for multiple programming languages
- **Collapsible Blocks**: Automatically collapse unchanged sections for better readability
- **Multiple View Modes**: Switch between unified diff, split view, original text, and modified text
- **Copy to Clipboard**: Easy copying of diff content
- **Line Numbers**: Accurate line number mapping
- **Cross-platform**: Supports both macOS and iOS

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

### Basic Usage

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
    let gitDiffOutput: String

    var body: some View {
        // Parse unified diff format
        let diffLines = MyersDiffAlgorithm.parseUnifiedDiffSafely(gitDiffOutput)

        return MagicDiffView(diffLines: diffLines)
    }
}
```

### Advanced: Custom Diff Computation

```swift
let oldLines = ["Line 1", "Line 2 old"]
let newLines = ["Line 1", "Line 2 new", "Line 3"]

// Use Myers algorithm for optimal diff
let diffLines = MyersDiffAlgorithm.computeDiff(
    oldLines: oldLines,
    newLines: newLines
)
```

## API Overview

### `MagicDiffView` Component

```swift
init(
    oldText: String,
    newText: String,
    showLineNumbers: Bool = true,
    contextLines: Int = 3
)

init(diffLines: [DiffLine])
```

### `MyersDiffAlgorithm`

```swift
// Compute diff from two text arrays
static func computeDiff(
    oldLines: [String],
    newLines: [String]
) -> [DiffLine]

// Parse unified diff format (throws)
static func parseUnifiedDiff(
    _ unifiedDiffText: String
) throws -> [DiffLine]

// Parse unified diff format (safe)
static func parseUnifiedDiffSafely(
    _ unifiedDiffText: String
) -> [DiffLine]
```

## Supported Diff Formats

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
+    let age: Int
 }
```

## Requirements

- iOS 17.0+ or macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Performance

- **Small files** (<100 lines): Optimized for instant results
- **Large files** (1000+ lines): O(ND) algorithm with O(N) space complexity
- **Massive files** (10000+ lines): Memory-efficient rolling array optimization

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Based on Eugene Myers' classic paper "An O(ND) Difference Algorithm and Its Variations" (1986)
- Inspired by GitHub Desktop's diff view implementation
