import Foundation
import ObjectiveC
#if os(macOS)
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
            if let textField = subview as? NSTextField {
                if let placeholder = textField.placeholderString, !placeholder.isEmpty {
                    textField.localizationKey = placeholder
                    textField.placeholderString = placeholder.localized()
                } else {
                    let text = textField.stringValue
                    textField.localizationKey = text
                    textField.stringValue = text.localized()
                }
            } else if let button = subview as? NSButton {
                let text = button.stringValue
                button.localizationKey = text
                button.stringValue = text.localized()
            } else if let textField = subview as? NSTextField, let placeholder = textField.placeholderString {
                textField.localizationKey = placeholder
                textField.placeholderString = placeholder.localized()
            }else if let collection = subview as? NSCollectionView{
                collection.reloadData()
            }else if let segment = subview as? NSSegmentedControl {
                for index in 0..<segment.segmentCount {
                    if let title = segment.label(forSegment: index){
                        segment.localizationKey = title
                        segment.setLabel(title.localized(), forSegment: index)
                    }
                }
            }else if let tableView = subview as? NSTableView{
                tableView.reloadVisibleCurrentRows()
            }
            localizeViewHierarchy(view: subview)
        }
    }
    @MainActor open class func resetToLocalizationKeys(view: NSView) {
        for subview in view.subviews {
            if let textField = subview as? NSTextField, let key = textField.localizationKey {
                if let placeholder = textField.placeholderString, !placeholder.isEmpty {
                    textField.placeholderString = key
                } else {
                    textField.stringValue = key
                }
            }else if let button = subview as? NSButton, let key = button.localizationKey {
                button.stringValue = key
            } else if let textField = subview as? NSTextField, let key = textField.localizationKey {
                textField.placeholderString = key
            }else if let collection = subview as? NSCollectionView{
                collection.reloadData()
            }else if let segment = subview as? NSSegmentedControl {
                for index in 0..<segment.segmentCount {
                    if let key = segment.localizationKey {
                        segment.setLabel(key, forSegment: index)
                    }
                }
            }else if let tableView = subview as? NSTableView{
                tableView.reloadVisibleCurrentRows()
            }
            resetToLocalizationKeys(view: subview)
        }
    }
}
#endif

