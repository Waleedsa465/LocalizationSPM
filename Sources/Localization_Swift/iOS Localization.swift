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
            }else if let segment = subview as? UISegmentedControl{
                for index in 0..<segment.numberOfSegments {
                    if let title = segment.titleForSegment(at: index) {
                        segment.localizationKey = title
                        segment.setTitle(title.localized(), forSegmentAt: index)
                    }
                }
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
                for index in 0..<segment.numberOfSegments {
                    if let key = segment.localizationKey {
                        segment.setTitle(key, forSegmentAt: index)
                    }
                }
            }
            resetToLocalizationKeys(view: subview)
        }
    }
}
// MARK: - UiTabbarController
extension UITabBarItem {
    private static var localizationKeyAssociatedObjectKey: UInt8 = 0
    
    var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &Self.localizationKeyAssociatedObjectKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &Self.localizationKeyAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension LocalizationUtility {
    @MainActor
    public class func localizeTabBarItems(in tabBarController: UITabBarController?) {
        for viewController in tabBarController?.viewControllers ?? [] {
            guard let tabBarItem = viewController.tabBarItem,
                  let title = tabBarItem.title else { continue }
            
            tabBarItem.localizationKey = title
            tabBarItem.title = title.localized()
        }
    }
    
    @MainActor
    public class func resetTabBarItemsToKeys(in tabBarController: UITabBarController?) {
        for viewController in tabBarController?.viewControllers ?? [] {
            guard let tabBarItem = viewController.tabBarItem,
                  let key = tabBarItem.localizationKey else { continue }
            
            tabBarItem.title = key
        }
    }
}
#endif
