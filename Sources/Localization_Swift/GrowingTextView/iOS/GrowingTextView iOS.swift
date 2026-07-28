#if os(iOS)
import UIKit

public protocol GrowingTextViewDelegate: AnyObject {
    func textViewDidChange(_ textView: UITextView)
}

@IBDesignable
@MainActor
open class GrowingTextView: PlaceholderTextView, UITextViewDelegate {

    @IBInspectable public var maxNumberOfLines: Int = 6 {
        didSet { recalculateHeight() }
    }
    public weak var growingDelegate: GrowingTextViewDelegate?
    @IBInspectable public var minimumHeightConstrait: CGFloat = 48.0

    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Initial Setup
    override open func awakeFromNib() {
        super.awakeFromNib()
        Task { @MainActor in commonInit() }
    }

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = true
        isEditable = true
        delegate = self

        if heightConstraint == nil {
            heightConstraint = heightAnchor.constraint(equalToConstant: minimumHeightConstrait)
            heightConstraint?.isActive = true
        }
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        Task { @MainActor in
            commonInit()
            recalculateHeight()
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - UITextViewDelegate Method
    open func textViewDidChange(_ textView: UITextView) {
        growingDelegate?.textViewDidChange(textView)
        recalculateHeight()
    }

    // MARK: - Recalculation of Height
    open func recalculateHeight() {
        guard let font = font else { return }
        let textHeight = contentSize.height
        let lineHeight = font.lineHeight + 4
        let maxHeight = lineHeight * CGFloat(maxNumberOfLines)
        let finalHeight = min(maxHeight, textHeight)
        heightConstraint?.constant = max(finalHeight, lineHeight + 12)
    }

    // MARK: - Layout Handling
    override open func layoutSubviews() {
        super.layoutSubviews()
        recalculateHeight()
    }
}

extension UIFont {
    var lineHeight: CGFloat {
        return ascender + abs(descender) + leading
    }
}
#endif
