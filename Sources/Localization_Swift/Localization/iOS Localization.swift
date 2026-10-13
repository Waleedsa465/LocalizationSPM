import Foundation
import ObjectiveC
#if os(iOS)
import UIKit

nonisolated(unsafe) public var localizationKeyAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) public var localizationKeysAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) public var localizationKeyTabBarAssociatedObjectKey: UInt8 = 0

extension UIView {
    var localizationKey: String? {
        get { objc_getAssociatedObject(self, &localizationKeyAssociatedObjectKey) as? String }
        set { objc_setAssociatedObject(self, &localizationKeyAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var viewController: UIViewController? {
        var nextResponder: UIResponder? = self
        while nextResponder != nil {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UISegmentedControl {
    var localizationKeys: [String?] {
        get { objc_getAssociatedObject(self, &localizationKeysAssociatedObjectKey) as? [String?] ?? [] }
        set { objc_setAssociatedObject(self, &localizationKeysAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension UITabBar {
    var localizationKeys: [String?] {
        get { objc_getAssociatedObject(self, &localizationKeyTabBarAssociatedObjectKey) as? [String?] ?? [] }
        set { objc_setAssociatedObject(self, &localizationKeyTabBarAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension LocalizationUtility {
    @MainActor
    class func localizeView(_ view: PlatformView) {
        if let label = view as? UILabel {
            if let key = label.localizationKey ?? label.text.nonEmpty {
                label.localizationKey = key
                label.text = key.localized()
            }
        } else if let button = view as? UIButton {
            if let key = button.localizationKey ?? button.title(for: .normal).nonEmpty {
                button.localizationKey = key
                button.setTitle(key.localized(), for: .normal)
            }
        } else if let textField = view as? UITextField {
            if let key = textField.localizationKey ?? textField.placeholder.nonEmpty {
                textField.localizationKey = key
                textField.placeholder = key.localized()
            }
        } else if let collection = view as? UICollectionView {
            collection.reloadData()
        } else if let segment = view as? UISegmentedControl {
            if segment.localizationKeys.isEmpty {
                segment.localizationKeys = (0..<segment.numberOfSegments).map { segment.titleForSegment(at: $0) ?? "" }
            }
            applySegmentTitles(segment, localized: true)
        } else if let tableView = view as? UITableView {
            tableView.reloadVisibleCurrentRows()
        } else if let tabBar = view as? UITabBar {
            applyTabBarTitles(tabBar, localized: true)
        }
    }
    
    @MainActor
    class func resetView(_ view: PlatformView) {
        if let label = view as? UILabel, let key = label.localizationKey {
            label.text = key
        } else if let button = view as? UIButton, let key = button.localizationKey {
            button.setTitle(key, for: .normal)
        } else if let textField = view as? UITextField, let key = textField.localizationKey {
            textField.placeholder = key
        } else if let collection = view as? UICollectionView {
            collection.reloadData()
        } else if let segment = view as? UISegmentedControl {
            applySegmentTitles(segment, localized: false)
        } else if let tableView = view as? UITableView {
            tableView.reloadVisibleCurrentRows()
        } else if let tabBar = view as? UITabBar {
            applyTabBarTitles(tabBar, localized: false)
        }
    }
    
    
    @MainActor
    fileprivate class func applySegmentTitles(_ segment: UISegmentedControl, localized: Bool) {
        let keys = segment.localizationKeys
        for index in 0..<segment.numberOfSegments {
            if let key = keys[safe: index] ?? nil {
                segment.setTitle(localized ? key.localized() : key, forSegmentAt: index)
            }
        }
    }
    
    @MainActor
    fileprivate class func applyTabBarTitles(_ tabBar: UITabBar, localized: Bool) {
        guard let items = tabBar.items else { return }
        if tabBar.localizationKeys.isEmpty {
            tabBar.localizationKeys = items.map { $0.title ?? "" }
        }
        let keys = tabBar.localizationKeys
        for (index, item) in items.enumerated() {
            if let key = keys[safe: index] ?? nil, !key.isEmpty {
                item.title = localized ? key.localized() : key
            }
        }
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }
}

extension UITabBarController {
    @MainActor
    func localizedTabbars() {
        LocalizationUtility.applyTabBarTitles(tabBar, localized: true)
    }
}

private extension Optional where Wrapped == String {
    var nonEmpty: String? {
        guard let self, !self.isEmpty else { return nil }
        return self
    }
}
#endif
