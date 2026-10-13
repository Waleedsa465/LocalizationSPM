#if os(macOS)
import Foundation
import AppKit

public protocol PlaceholderTextViewDelegate: AnyObject {
    func didPressEnter(withText text: String)
}
public protocol PlaceholderTextViewResponderDelegate: AnyObject {
    func textViewDidBecomeFirstResponder()
    func textViewDidResignFirstResponder()
}

@IBDesignable
@MainActor
open class PlaceholderTextView: NSTextView {

    @IBInspectable public var placeholderString: String = "" {
        didSet { refreshPlaceholder() }
    }

    @IBInspectable public var placeholderColor: NSColor = .placeholderTextColor {
        didSet { refreshPlaceholder() }
    }

    private let placeholderLabel: NSTextField = {
        let label = PassthroughLabel(wrappingLabelWithString: "")
        label.isSelectable = false
        label.isEditable = false
        label.drawsBackground = false
        label.isBordered = false
        label.maximumNumberOfLines = 0
        return label
    }()

    public weak var enterDelegate: PlaceholderTextViewDelegate?
    public weak var responderDelegate: PlaceholderTextViewResponderDelegate?

    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

    // MARK: - Initialisers
    public override init(frame: NSRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        addSubview(placeholderLabel)
        refreshPlaceholder()
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }

    @objc private func languageDidChange() {
        refreshPlaceholder()
    }

    private func refreshPlaceholder() {
        placeholderLabel.stringValue = placeholderString.localized()
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        placeholderLabel.alignment = alignment
        placeholderLabel.isHidden = !string.isEmpty || isFieldEditor

        let dx = textContainerInset.width + textContainerOrigin.x + 5
        let dy = textContainerInset.height + textContainerOrigin.y
        let width = max(bounds.width - dx * 2, 0)
        let height = placeholderLabel.cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)).height ?? 0
        placeholderLabel.frame = NSRect(x: dx, y: dy, width: width, height: height)
    }

    open override func layout() {
        super.layout()
        refreshPlaceholder()
    }

    open override func didChangeText() {
        super.didChangeText()
        refreshPlaceholder()
    }

    open override var string: String {
        didSet { refreshPlaceholder() }
    }

    // MARK: - IBDesignable Preview Support
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        Task { @MainActor in refreshPlaceholder() }
    }

    // MARK: - First Responder
    open override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        responderDelegate?.textViewDidBecomeFirstResponder()
        return success
    }

    open override func resignFirstResponder() -> Bool {
        let success = super.resignFirstResponder()
        responderDelegate?.textViewDidResignFirstResponder()
        return success
    }

    // MARK: - Key Handling
    open override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
            if event.modifierFlags.contains(.shift) {
                insertNewline(nil)
            } else {
                enterDelegate?.didPressEnter(withText: string)
            }
        } else {
            super.keyDown(with: event)
        }
    }

    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.type == .keyDown,
              let characters = event.charactersIgnoringModifiers else {
            return super.performKeyEquivalent(with: event)
        }

        let flags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue

        if flags == commandKey {
            switch characters {
            case "x": if NSApp.sendAction(#selector(NSText.cut(_:)),       to: nil, from: self) { return true }
            case "c": if NSApp.sendAction(#selector(NSText.copy(_:)),      to: nil, from: self) { return true }
            case "v": if NSApp.sendAction(#selector(NSText.paste(_:)),     to: nil, from: self) { return true }
            case "z": if NSApp.sendAction(Selector(("undo:")),             to: nil, from: self) { return true }
            case "a": if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
            default: break
            }
        } else if flags == commandShiftKey {
            if characters == "Z" {
                if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
            }
        }

        return super.performKeyEquivalent(with: event)
    }
}

private final class PassthroughLabel: NSTextField {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
#endif
