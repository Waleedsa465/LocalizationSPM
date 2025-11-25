//
//  File.swift
//  Localization_Swift
//
//  Created by Macbook Pro M1 on 25/11/2025.
//

import Foundation

#if os(iOS)
import UIKit

// MARK: - iOS Localization

@IBDesignable public extension UILabel {
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
