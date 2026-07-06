#if os(macOS)
import Cocoa

// MARK: - Make View Return 
@IBDesignable
@MainActor
open class NonClickableView: NSView {
    open override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(nil)
    }
}
#endif
