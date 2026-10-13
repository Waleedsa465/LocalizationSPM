#if os(iOS)
import Foundation
import UIKit

@IBDesignable
@MainActor
open class PlaceholderTextView: UITextView {
    
    
    private let placeholderLabel: UILabel = UILabel()
    
    @IBInspectable public var placeholder: String? {
        didSet { updatePlaceholderText() }
    }
    
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    public var placeHolderFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    open override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    open override var font: UIFont? {
        didSet {
            placeholderLabel.font = placeHolderFont
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        Task{ @MainActor in
            setupPlaceholder()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame.origin = CGPoint(x: textContainerInset.left + 5, y: textContainerInset.top)
        placeholderLabel.frame.size.width = frame.width - textContainerInset.left - textContainerInset.right
    }
    
    func setupPlaceholder() {
        addSubview(placeholderLabel)
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeHolderFont
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.backgroundColor = .clear
        textDidChange()
        updatePlaceholderText()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    private func updatePlaceholderText() {
        placeholderLabel.text = placeholder?.localized()
        placeholderLabel.sizeToFit()
        setNeedsLayout()
    }
    
    @objc private func languageDidChange() {
        updatePlaceholderText()
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    @MainActor deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
#endif
