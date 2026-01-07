# MagicDiffView

A SwiftUI view component for comparing and displaying text differences, similar to GitHub Desktop's diff view.

> 📖 [中文文档](README_zh-CN.md)

## Features

- **Text Diff Comparison**: Compare two text strings and highlight differences
- **Syntax Highlighting**: Support for Swift and JavaScript syntax highlighting
- **Collapsible Blocks**: Automatically collapse unchanged sections for better readability
- **Multiple View Modes**: Switch between diff view, original text, and modified text
- **Copy to Clipboard**: Easy copying of diff content
- **Line Numbers**: Optional display of line numbers
- **Cross-platform**: Supports both macOS and iOS

## Usage

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

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/MagicDiffView.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Open your project in Xcode
2. Go to File > Swift Packages > Add Package Dependency
3. Enter the repository URL: `https://github.com/your-username/MagicDiffView.git`

## Requirements

- iOS 17.0+ or macOS 14.0+
- Swift 5.9+

## License

This package is licensed under the MIT License. See LICENSE file for details.
