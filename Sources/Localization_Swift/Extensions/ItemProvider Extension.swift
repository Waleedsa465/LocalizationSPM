#if os(iOS)
import UIKit
import Foundation

public extension NSItemProvider {
    func loadImage() async -> UIImage? {
        await withCheckedContinuation { continuation in
            loadObject(ofClass: UIImage.self) { image, _ in
                continuation.resume(returning: image as? UIImage)
            }
        }
    }
}
#endif
