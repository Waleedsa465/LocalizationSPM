#if os(macOS)
import Foundation
import AppKit

public protocol PlaceholderTextViewDelegate: AnyObject {
    func didPressEnter(withText text: String)
}

@IBDesignable
@MainActor
open class PlaceholderTextView: NSTextView {

    @IBInspectable public var placeholderString: String = "" {
        didSet { needsDisplay = true }
    }

    @IBInspectable public var placeholderColor: NSColor = .placeholderTextColor {
        didSet { needsDisplay = true }
    }

    public weak var enterDelegate: PlaceholderTextViewDelegate?

    // MARK: - Private Helpers
    private var placeholderAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: placeholderColor,
            .font: font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .paragraphStyle: currentParagraphStyle
        ]
    }

    private var currentParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        return style
    }

    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

    // MARK: - Initialisers
    public override init(frame: NSRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - IBDesignable Preview Support
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        Task { @MainActor in needsDisplay = true }
    }

    // MARK: - Drawing
    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard string.isEmpty, !isFieldEditor else { return }

        let placeholderRect = bounds.insetBy(
            dx: textContainerInset.width + textContainerOrigin.x + 5,
            dy: textContainerInset.height + textContainerOrigin.y
        )
        placeholderString.draw(
            with: placeholderRect,
            options: .usesLineFragmentOrigin,
            attributes: placeholderAttributes
        )
    }

    // MARK: - First Responder
    open override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        needsDisplay = true
        return success
    }

    open override func resignFirstResponder() -> Bool {
        let success = super.resignFirstResponder()
        needsDisplay = true
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
#endif // os(macOS)
