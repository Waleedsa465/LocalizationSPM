#if os(macOS)

import Cocoa

// MARK: - Main Class
@MainActor
final class DraggableImageView: NSImageView, NSDraggingSource {
    
    // MARK: Properties
    private var mouseDownEvent: NSEvent?
    private var isDragging = false
    private var quickLookHandler: QuickLookHandler?
    
    // MARK: Init
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        quickLookHandler = QuickLookHandler(imageView: self)
    }
    private func setup() {
        quickLookHandler = QuickLookHandler(imageView: self)
        focusRingType = .none
        isEditable = true
        registerForDraggedTypes([.fileURL])
    }
    
    // MARK: - Mouse Events
    override func mouseDown(with event: NSEvent) {
        mouseDownEvent = event
        isDragging = false
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard !isDragging else { return }
        guard let mouseDownEvent = mouseDownEvent else { return }
        guard let image = self.image else { return }
        
        let startPoint = mouseDownEvent.locationInWindow
        let currentPoint = event.locationInWindow
        let distance = hypot(startPoint.x - currentPoint.x, startPoint.y - currentPoint.y)
        guard distance >= 5 else { return }
        isDragging = true
        let provider = NSFilePromiseProvider(fileType: "public.png", delegate: self)
        provider.userInfo = image
        let draggingItem = NSDraggingItem(pasteboardWriter: provider)
        let previewSize = NSSize(width: 60, height: 60)
        let preview = image.resizeMaintainingAspectRatio(withSize: previewSize)
        let origin = convert(mouseDownEvent.locationInWindow, from: nil)
        draggingItem.draggingFrame = NSRect(origin: origin, size: preview.size)
        draggingItem.imageComponentsProvider = {
            let component = NSDraggingImageComponent(key: .icon)
            component.contents = preview
            component.frame = NSRect(origin: .zero, size: preview.size)
            return [component]
            
        }
        beginDraggingSession(with: [draggingItem], event: mouseDownEvent, source: self)
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseDownEvent = nil
        if event.clickCount == 1 {
            quickLookHandler?.showPreview()
        }
        if !isDragging {
            do {
                try saveImageToDesktop()
                print("Image saved to desktop!")
            } catch {
                print("Failed to save image: \(error)")
            }
        }
        isDragging = false
    }
    
    // MARK: - NSDraggingSource
    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
    
    func draggingSession(_ session: NSDraggingSession,
                         endedAt screenPoint: NSPoint,
                         operation: NSDragOperation) {
        if operation == .delete {
            image = nil
        }
        isDragging = false
    }
    
    // MARK: - Save on Click (Optional)
    func saveImageToDesktop() throws {
        guard let image = self.image else {
            throw NSError(domain: "DraggableImageView", code: -1,userInfo: [NSLocalizedDescriptionKey: "No image to save"])
        }
        
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let fileURL = desktopURL.appendingPathComponent("\(String(UUID().uuidString).prefix(8)).png")
        
        try image.savePngTo(url: fileURL)
    }
}

// MARK: - NSFilePromiseProviderDelegate
extension DraggableImageView: NSFilePromiseProviderDelegate {
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider,fileNameForType fileType: String) -> String {
        "\(String(UUID().uuidString).prefix(8)).png"
    }
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider,writePromiseTo url: URL,completionHandler: @escaping (Error?) -> Void) {
        let image = filePromiseProvider.userInfo as? NSImage
        DispatchQueue.global(qos: .utility).async {
            guard let image = image, let pngData = image.pngRepresentation else {
                completionHandler(NSError(domain: "Drag", code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"]))
                return
            }
            
            do {
                try pngData.write(to: url, options: .atomic)
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }
}
#endif
