#if os(macOS)
import Cocoa

class NoArrowKeysCollectionView: NSCollectionView {
    
    override func keyDown(with event: NSEvent) {
        if [123, 124, 125, 126].contains(event.keyCode) { return }
        super.keyDown(with: event)
    }
    override func moveUp(_ sender: Any?) { }
    override func moveDown(_ sender: Any?) { }
    override func moveLeft(_ sender: Any?) { }
    override func moveRight(_ sender: Any?) { }
}
#endif
