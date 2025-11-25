//
//  File.swift
//  Localization_Swift
//
//  Created by Macbook Pro M1 on 25/11/2025.
//

import Foundation
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
            }else if let collection = subview as? UICollectionView{
                collection.reloadData()
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
            }else if let collection = subview as? UICollectionView{
                collection.reloadData()
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
            }else if let collection = subview as? NSCollectionView{
                collection.reloadData()
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
            }else if let collection = subview as? NSCollectionView{
                collection.reloadData()
            }
            resetToLocalizationKeys(view: subview)
        }
    }
}
#endif

