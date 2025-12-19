//
//  File.swift
//  Localization_Swift
//
//  Created by Macbook Pro M1 on 19/12/2025.
//

import Foundation
import ObjectiveC
#if os(iOS)
import UIKit

nonisolated(unsafe) public var localizationKeyAssociatedObjectKey: UInt8 = 0
nonisolated(unsafe) public var localizationKeysAssociatedObjectKey: UInt8 = 0

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
            }else if let segment = subview as? UISegmentedControl {
                let keys = segment.localizationKeys
                for index in 0..<segment.numberOfSegments {
                    if let key = keys[safe: index] {
                        segment.setTitle(key, forSegmentAt: index)
                    }
                }
            }else if let tabbar = subview as? UITabBar{
                print(tabbar,"tabbar")
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
            }else if let segment = subview as? UISegmentedControl {
                var keys = segment.localizationKeys
                if keys.isEmpty {
                    keys = (0..<segment.numberOfSegments).map { segment.titleForSegment(at: $0) }
                    segment.localizationKeys = keys
                }
                for index in 0..<segment.numberOfSegments {
                    if let key = keys[index] {
                        segment.setTitle(key.localized(), forSegmentAt: index)
                    }
                }
            }
            resetToLocalizationKeys(view: subview)
        }
    }
}
extension UISegmentedControl {
    var localizationKeys: [String?] {
        get {
            return objc_getAssociatedObject(self, &localizationKeysAssociatedObjectKey) as? [String?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &localizationKeysAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
// MARK: - UiTabbarController
extension UITabBar {
    var localizationKeys: [String?] {
        get {
            return objc_getAssociatedObject(self, &localizationKeysAssociatedObjectKey) as? [String?] ?? []
        }
        set {
            objc_setAssociatedObject(self, &localizationKeysAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
extension LocalizationUtility {
    
    @MainActor
    public class func localizeTabBarItems(in tabBarController: UITabBarController?) {
        guard let tabBar = tabBarController?.tabBar,
              let items = tabBar.items, !items.isEmpty else {
            return
        }
        
        var keys = tabBar.localizationKeys
        if keys.isEmpty {
            keys = items.map { $0.title }
            tabBar.localizationKeys = keys
        }
        for (index, item) in items.enumerated() {
            if let key = keys[safe: index], let localized = key?.localized(), !localized.isEmpty {
                item.title = localized
            }
        }
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }
    
    @MainActor
    public class func resetTabBarItemsToKeys(in tabBarController: UITabBarController?) {
        guard let tabBar = tabBarController?.tabBar,
              let items = tabBar.items else {
            return
        }
        
        let keys = tabBar.localizationKeys
        for (index, item) in items.enumerated() {
            if let key = keys[safe: index] {
                item.title = key
            }
        }
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }
}
#endif
