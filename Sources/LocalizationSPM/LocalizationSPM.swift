// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
#if os(iOS)
import UIKit

// MARK: - iOS Localization

@IBDesignable public extension UILabel {
    @IBInspectable var localizeKey: String? {
        set {
            // set new value from dictionary
            DispatchQueue.main.async {
                self.text = newValue?.localized()
            }
        }
        get {
            return self.text
        }
    }
}

@IBDesignable public extension UIButton {

    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.setTitle(newValue?.localized(), for: .normal)
            }
        }
        get {
            return self.titleLabel?.text
        }
    }
}
@IBDesignable public extension UITextView {

    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.text = newValue?.localized()
            }
        }
        get {
            return self.text
        }
    }
}
@IBDesignable public extension UITextField {
    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.placeholder = newValue?.localized()
            }
        }
        get {
            return self.placeholder
        }
    }
}
@IBDesignable public extension UINavigationItem {

    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.title = newValue?.localized()
            }
        }
        get {
            return self.title
        }
    }
}

// MARK: - MAC OS Localization

#elseif os(macOS)
import AppKit

@IBDesignable public extension NSTextField {
    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.stringValue = newValue?.localized() ?? ""
            }
        }
        get {
            return self.stringValue
        }
    }
}
@IBDesignable public extension NSButton {

    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.title = newValue?.localized() ?? ""
            }
        }
        get {
            return self.title
        }
    }
}

@IBDesignable public extension NSTextView {

    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.string = newValue?.localized() ?? ""
            }
        }
        get {
            return self.string
        }
    }
}
@IBDesignable public extension NSTextField {
    @IBInspectable var placeHolderLocalized: String? {
        set {
            DispatchQueue.main.async {
                self.placeholderString = newValue?.localized()
            }
        }
        get {
            return self.placeholderString
        }
    }
}
#endif

// MARK: - IoS and MacOS Localization Code Format
import ObjectiveC
#if os(iOS)
import UIKit

nonisolated(unsafe) public var localizationKeyAssociatedObjectKey: UInt8 = 0

extension UIView {
    var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationKeyAssociatedObjectKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &localizationKeyAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class LocalizationUtility: NSObject {
    public override init() {}
    @MainActor open class func localizeViewHierarchy(view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel, let text = label.text {
                label.localizationKey = text
                label.text = text.localized()
            } else if let button = subview as? UIButton, let text = button.title(for: .normal) {
                button.localizationKey = text
                button.setTitle(text.localized(), for: .normal)
            } else if let textField = subview as? UITextField, let placeholder = textField.placeholder {
                textField.localizationKey = placeholder
                textField.placeholder = placeholder.localized()
            }
            localizeViewHierarchy(view: subview)
        }
    }
    @MainActor open class func resetToLocalizationKeys(view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel, let key = label.localizationKey {
                label.text = key
            } else if let button = subview as? UIButton, let key = button.localizationKey {
                button.setTitle(key, for: .normal)
            } else if let textField = subview as? UITextField, let key = textField.localizationKey {
                textField.placeholder = key
            }
            resetToLocalizationKeys(view: subview)
        }
    }
}
#elseif os(macOS)
import AppKit

nonisolated(unsafe) public var localizationKeyAssociatedObjectKey: UInt8 = 0

extension NSView {
    var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationKeyAssociatedObjectKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &localizationKeyAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class LocalizationUtility: NSObject {
    
    public override init() { }
    
    @MainActor open class func localizeViewHierarchy(view: NSView) {
        for subview in view.subviews {
            if let label = subview as? NSTextField {
                let text = label.stringValue
                label.localizationKey = text
                label.stringValue = text.localized()
            } else if let button = subview as? NSButton {
                let text = button.stringValue
                button.localizationKey = text
                button.stringValue = text.localized()
            } else if let textField = subview as? NSTextField, let placeholder = textField.placeholderString {
                textField.localizationKey = placeholder
                textField.placeholderString = placeholder.localized()
            }
            localizeViewHierarchy(view: subview)
        }
    }
    @MainActor open class func resetToLocalizationKeys(view: NSView) {
        for subview in view.subviews {
            if let label = subview as? NSTextField, let key = label.localizationKey {
                label.stringValue = key
            } else if let button = subview as? NSButton, let key = button.localizationKey {
                button.stringValue = key
            } else if let textField = subview as? NSTextField, let key = textField.localizationKey {
                textField.placeholderString = key
            }
            resetToLocalizationKeys(view: subview)
        }
    }
}
#endif

