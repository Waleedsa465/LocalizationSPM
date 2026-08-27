#if os(iOS)
import UIKit
public typealias PlatformImageView = UIImageView
#elseif os(macOS)
import AppKit
public typealias PlatformImageView = NSImageView
#endif
import AVFoundation

public extension PlatformImageView {

    func getDisplayedImageFrame() -> CGRect? {
        guard let imageSize = self.image?.size else { return nil }
        return AVMakeRect(aspectRatio: imageSize, insideRect: bounds)
    }
}

public enum PlatformImageError: Error {
    case unwrappingPNGRepresentationFailed
}

public extension PlatformImage {

    var width: CGFloat { size.width }
    var height: CGFloat { size.height }

    var pngRepresentation: Data? {
        #if os(iOS)
        return pngData()
        #elseif os(macOS)
        guard let tiff = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
        #endif
    }

    func resize(withSize targetSize: CGSize) -> PlatformImage {
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        #elseif os(macOS)
        let frame = NSRect(origin: .zero, size: targetSize)
        guard let rep = bestRepresentation(for: frame, context: nil, hints: nil) else {
            return self
        }
        return NSImage(size: targetSize, flipped: false) { _ in
            rep.draw(in: frame)
        }
        #endif
    }

    func resizeMaintainingAspectRatio(withSize targetSize: CGSize) -> PlatformImage {
        let widthRatio = targetSize.width / width
        let heightRatio = targetSize.height / height
        let scale = max(widthRatio, heightRatio)
        let newSize = CGSize(width: width * scale, height: height * scale)
        return resize(withSize: newSize)
    }

    func savePngTo(url: URL) throws {
        guard let png = pngRepresentation else {
            throw PlatformImageError.unwrappingPNGRepresentationFailed
        }
        try png.write(to: url, options: .atomic)
    }
}
