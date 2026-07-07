#if os(macOS)
import Cocoa
import QuickLookUI

open class QuickLookHandler: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    private weak var imageView: NSImageView?
    private var previewURL: URL?
    
    init(imageView: NSImageView) {
        self.imageView = imageView
        super.init()
    }
    
    deinit {
        removeTemporaryFile()
    }
    
    @MainActor open func showPreview() {
        guard let image = imageView?.image else { return }
        
        do {
            let url = try createTemporaryFile(from: image)
            previewURL = url
            
            let panel = QLPreviewPanel.shared()
            panel?.dataSource = self
            panel?.delegate = self
            panel?.makeKeyAndOrderFront(nil)
        } catch {
            print("Quick Look failed: \(error.localizedDescription)")
        }
    }
    
    @MainActor func cleanup() {
        removeTemporaryFile()
        QLPreviewPanel.shared().close()
    }
    
    // MARK: - Private Helpers
    
    private func createTemporaryFile(from image: NSImage) throws -> URL {
        guard let pngData = image.pngRepresentation else {
            throw NSError(domain: "QuickLookHandler", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to get PNG data"])
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "Preview-\(String(UUID().uuidString).prefix(8)).png"
        let url = tempDir.appendingPathComponent(filename)
        
        try pngData.write(to: url, options: .atomic)
        return url
    }
    
    private func removeTemporaryFile() {
        if let url = previewURL {
            try? FileManager.default.removeItem(at: url)
            previewURL = nil
        }
    }
    
    // MARK: - QLPreviewPanelDataSource
    
    public func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return previewURL != nil ? 1 : 0
    }
    
    public func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        guard index == 0, let url = previewURL else { return nil }
        return url as QLPreviewItem
    }
}
#endif
