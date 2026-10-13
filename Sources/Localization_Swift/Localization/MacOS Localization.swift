import Foundation
import ObjectiveC
#if os(macOS)
import AppKit

nonisolated(unsafe) public var localizationKeyAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) public var localizationKeysAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) public var localizationPlaceholderKeyAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) fileprivate var localizationAppliedTextAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) fileprivate var localizationAppliedPlaceholderAssociatedObjectKey: UInt8 = 0

extension NSTextField {
    var localizationPlaceholderKey: String? {
        get { objc_getAssociatedObject(self, &localizationPlaceholderKeyAssociatedObjectKey) as? String }
        set { objc_setAssociatedObject(self, &localizationPlaceholderKeyAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    fileprivate var appliedText: String? {
        get { objc_getAssociatedObject(self, &localizationAppliedTextAssociatedObjectKey) as? String }
        set { objc_setAssociatedObject(self, &localizationAppliedTextAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var appliedPlaceholder: String? {
        get { objc_getAssociatedObject(self, &localizationAppliedPlaceholderAssociatedObjectKey) as? String }
        set { objc_setAssociatedObject(self, &localizationAppliedPlaceholderAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension NSSegmentedControl {
    var localizationKeys: [String?] {
        get { objc_getAssociatedObject(self, &localizationKeysAssociatedObjectKey) as? [String?] ?? [] }
        set { objc_setAssociatedObject(self, &localizationKeysAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

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

extension LocalizationUtility {
    
    private class func resolveKey(current: String, storedKey: String?, applied: String?) -> String? {
        guard !current.isEmpty else { return nil }
        let key = (storedKey != nil && current == applied) ? storedKey! : current
        return key.hasLocalization() ? key : nil
    }
    @MainActor
    class func localizeView(_ view: PlatformView) {
        if let textField = view as? NSTextField {
            let placeholder = textField.placeholderString ?? ""
            if let key = resolveKey(current: placeholder, storedKey: textField.localizationPlaceholderKey, applied: textField.appliedPlaceholder) {
                let value = key.localized()
                textField.localizationPlaceholderKey = key
                textField.placeholderString = value
                textField.appliedPlaceholder = value
            } else {
                textField.localizationPlaceholderKey = nil
            }
            let text = textField.stringValue
            if let key = resolveKey(current: text, storedKey: textField.localizationKey, applied: textField.appliedText) {
                let value = key.localized()
                textField.localizationKey = key
                textField.stringValue = value
                textField.appliedText = value
            } else {
                textField.localizationKey = nil
            }
        } else if let button = view as? NSButton {
            let text = button.localizationKey ?? button.title
            button.localizationKey = text
            button.title = text.localized()
        }else if let collection = view as? NSCollectionView{
            collection.reloadData()
        }else if let segment = view as? NSSegmentedControl {
            if segment.localizationKeys.isEmpty {
                segment.localizationKeys = (0..<segment.segmentCount).map { segment.label(forSegment: $0) }
            }
            let keys = segment.localizationKeys
            for index in 0..<segment.segmentCount {
                if let key = keys[safe: index] ?? nil, !key.isEmpty {
                    segment.setLabel(key.localized(), forSegment: index)
                }
            }
        }else if let tableView = view as? NSTableView{
            tableView.reloadVisibleCurrentRows()
        }
    }
    
    @MainActor
    class func resetView(_ view: PlatformView) {
        if let textField = view as? NSTextField {
            if let key = textField.localizationPlaceholderKey, textField.placeholderString == textField.appliedPlaceholder {
                textField.placeholderString = key
                textField.appliedPlaceholder = key
            }
            if let key = textField.localizationKey, textField.stringValue == textField.appliedText {
                textField.stringValue = key
                textField.appliedText = key
            }
        }else if let button = view as? NSButton, let key = button.localizationKey {
            button.title = key
        }else if let collection = view as? NSCollectionView{
            collection.reloadData()
        }else if let segment = view as? NSSegmentedControl {
            let keys = segment.localizationKeys
            for index in 0..<segment.segmentCount {
                if let key = keys[safe: index] ?? nil {
                    segment.setLabel(key, forSegment: index)
                }
            }
        }else if let tableView = view as? NSTableView{
            tableView.reloadVisibleCurrentRows()
        }
    }
}
#endif
