#if os(iOS)
import UIKit
public typealias PlatformImageView = UIImageView
#elseif os(macOS)
import AppKit
public typealias PlatformImageView = NSImageView
#endif
import AVFoundation

public extension PlatformImageView {
    
    func getDisplayedImageFrame()  -> CGRect? {
        guard let imageSize = self.image?.size else { return nil }
        return AVMakeRect(aspectRatio: imageSize, insideRect: bounds)
    }
}
