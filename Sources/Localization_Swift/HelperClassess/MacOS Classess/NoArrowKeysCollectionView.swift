#if os(macOS)
import Cocoa

@IBDesignable
@MainActor
open class NoArrowKeysCollectionView: NSCollectionView {
    
    open override func keyDown(with event: NSEvent) {
        if [123, 124, 125, 126].contains(event.keyCode) { return }
        super.keyDown(with: event)
    }
    open override func moveUp(_ sender: Any?) { }
    open override func moveDown(_ sender: Any?) { }
    open override func moveLeft(_ sender: Any?) { }
    open override func moveRight(_ sender: Any?) { }
}
#endif
