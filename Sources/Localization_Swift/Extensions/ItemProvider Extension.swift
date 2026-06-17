#if os(iOS)
import UIKit
public typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#endif

import Foundation

public extension NSItemProvider {
    func loadImage() async -> PlatformImage? {
#if os(macOS)
        if #available(macOS 13.0, *) {
            return await withCheckedContinuation { continuation in
                loadObject(ofClass: PlatformImage.self) { image, _ in
                    continuation.resume(returning: image as? PlatformImage)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                loadDataRepresentation(forTypeIdentifier: "public.image") { data, _ in
                    guard let data else { return continuation.resume(returning: nil) }
                    continuation.resume(returning: NSImage(data: data))
                }
            }
        }
#else
        return await withCheckedContinuation { continuation in
            loadObject(ofClass: PlatformImage.self) { image, _ in
                continuation.resume(returning: image as? PlatformImage)
            }
        }
#endif
    }
}
