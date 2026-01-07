#if DEBUG
import SwiftUI

/// 混合变更演示
struct MixedChangesDiffView: View {
    var body: some View {
        MagicDiffView(
            oldText: "class ImageLoader {\n    private var cache: [URL: UIImage] = [:]\n    \n    func loadImage(from url: URL) -> UIImage? {\n        if let cached = cache[url] {\n            return cached\n        }\n        \n        // 从网络加载图片\n        return nil\n    }\n}",
            newText: "class ImageLoader {\n    private var cache: [URL: UIImage] = [:]\n    private let queue = DispatchQueue(label: \"com.app.imageloader\")\n    \n    func loadImage(from url: URL) async throws -> UIImage {\n        if let cached = cache[url] {\n            return cached\n        }\n        \n        let (data, _) = try await URLSession.shared.data(from: url)\n        guard let image = UIImage(data: data) else {\n            throw ImageError.invalidData\n        }\n        \n        queue.async {\n            self.cache[url] = image\n        }\n        \n        return image\n    }\n    \n    enum ImageError: Error {\n        case invalidData\n    }\n}"
        )
    }
}

// MARK: - Preview

#Preview("混合变更") {
    MixedChangesDiffView()
        .frame(height: 600)
}
#endif
