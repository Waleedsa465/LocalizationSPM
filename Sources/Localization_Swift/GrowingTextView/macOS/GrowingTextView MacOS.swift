#if os(macOS)
import Foundation
import AppKit

@IBDesignable
@MainActor
open class GrowingTextScrollView: NSScrollView {
    
    @IBInspectable public var maxNumberOfLines: Int = 8 {
        didSet { recalculateHeight() }
    }
    
    @IBInspectable public var minimumHeightConstrait: CGFloat = 41.0
    
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Initial Setup
    open override func awakeFromNib() {
        super.awakeFromNib()
        Task{ @MainActor in commonInit() }
    }
    
    private func commonInit() {
        drawsBackground = false
        hasVerticalScroller = false
        hasHorizontalScroller = false
        
        if let textView = documentView as? NSTextView {
            textView.isVerticallyResizable = true
            textView.isHorizontallyResizable = false
            textView.textContainer?.widthTracksTextView = true
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textDidChangeType),
                name: NSText.didChangeNotification,
                object: textView
            )
        }
        
        if heightConstraint == nil {
            if let hc = constraints.first(where: { $0.firstAttribute == .height }) {
                heightConstraint = hc
            } else {
                heightConstraint = heightAnchor.constraint(equalToConstant: minimumHeightConstrait)
                heightConstraint?.isActive = true
            }
        }
    }
    // MARK: - Text Change Observer
    @objc open func textDidChangeType() {
        recalculateHeight()
    }
    
    // MARK: - Recalculation of Height
    open func recalculateHeight() {
        guard let textView = documentView as? NSTextView,
              let font = textView.font ,let textContainer = textView.textContainer else { return }
        
        let textHeight = textView.layoutManager?.usedRect(for: textContainer).height ?? minimumHeightConstrait
        let lineHeight = font.lineHeight + 4
        let maxHeight = lineHeight * CGFloat(maxNumberOfLines) + textView.textContainerInset.height * 2
        let finalHeight = min(maxHeight, textHeight + textView.textContainerInset.height * 2)
        heightConstraint?.constant = max(finalHeight, lineHeight + 12) // at least 1 line tall
    }
    
    // MARK: - Layout Handling
    open override func layout() {
        super.layout()
        recalculateHeight()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NSFont {
    public var lineHeight: CGFloat {
        return ascender + abs(descender) + leading
    }
}
#endif // os(macOS)
