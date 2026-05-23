#if os(macOS)
import Cocoa

// MARK: - Make View Return 
class NonClickableView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(nil)
    }
}
#endif
