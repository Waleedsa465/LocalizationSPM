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

open class LocalizationUtility: NSObject {
    public override init() {}
    
    @MainActor
    open class func localizeViewHierarchy(view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel, let text = label.text, !text.isEmpty {
                label.localizationKey = text
                label.text = text.localized()
            } else if let button = subview as? UIButton, let text = button.title(for: .normal), !text.isEmpty {
                button.localizationKey = text
                button.setTitle(text.localized(), for: .normal)
            } else if let textField = subview as? UITextField, let placeholder = textField.placeholder, !placeholder.isEmpty {
                textField.localizationKey = placeholder
                textField.placeholder = placeholder.localized()
            } else if let collection = subview as? UICollectionView {
                collection.reloadData()
            }
            // Segmented Control
            else if let segment = subview as? UISegmentedControl {
                var keys = segment.localizationKeys
                if keys.isEmpty {
                    keys = (0..<segment.numberOfSegments).map { segment.titleForSegment(at: $0) ?? "" }
                    segment.localizationKeys = keys
                }
                for index in 0..<segment.numberOfSegments {
                    if let key = keys[safe: index], let localized = key?.localized() {
                        segment.setTitle(localized, forSegmentAt: index)
                    }
                }
            }else if let tableView = subview as? UITableView{
                tableView.reloadVisibleCurrentRows()
            }
            else if let tabBar = subview as? UITabBar {
                guard let items = tabBar.items else{
                    return
                }
                var keys = tabBar.localizationKeys
                print("TabBar Localization Keys: \(keys)")
                
                // Save original titles ONLY if empty (first time)
                if keys.isEmpty {
                    keys = items.map { $0.title ?? "" }
                    tabBar.localizationKeys = keys
                    print("TabBar Keys saved: \(keys)")
                }
                
                // Apply localized titles
                for index in 0..<items.count {
                    if let key = keys[safe: index],let key {
                        print("TabBar item \(index) localizing title: \(key) -> localized: \(key.localized())")
                        items[index].title = key.localized()
                    }
                }
                
                // Force tab bar to redraw (critical!)
                tabBar.setNeedsLayout()
                tabBar.layoutIfNeeded()
                print("TabBar layout updated")
            } else if let viewController = view.viewController {
                if let tabBarController = viewController as? UITabBarController {
                    tabBarController.localizedTabbars()
                }else if let navigationController = viewController as? UINavigationController {
                    // Working Soon
                }
            }
            
            localizeViewHierarchy(view: subview)
        }
    }
    
    @MainActor
    open class func resetToLocalizationKeys(view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel, let key = label.localizationKey {
                label.text = key
            } else if let button = subview as? UIButton, let key = button.localizationKey {
                button.setTitle(key, for: .normal)
            } else if let textField = subview as? UITextField, let key = textField.localizationKey {
                textField.placeholder = key
            } else if let collection = subview as? UICollectionView {
                collection.reloadData()
            }
            // Segmented Control reset
            else if let segment = subview as? UISegmentedControl {
                let keys = segment.localizationKeys
                for index in 0..<segment.numberOfSegments {
                    if let key = keys[safe: index] {
                        segment.setTitle(key, forSegmentAt: index)
                    }
                }
            }else if let tableView = subview as? UITableView{
                tableView.reloadVisibleCurrentRows()
            }
            else if let tabBar = subview as? UITabBar{
                guard let items = tabBar.items else{
                    return
                }
                
                var titlesArray: [String] = []
                
                for index in 0..<items.count {
                    if let key = tabBar.localizationKeys[safe: index],let key {
                        print("Resetting TabBar item \(index) with key: \(key)")
                        items[index].title = key
                        titlesArray.append(key)
                    }
                }
                tabBar.setNeedsLayout()
                tabBar.layoutIfNeeded()
                print("TabBar layout updated")
            }
            else if let viewController = view.viewController {
                if let tabBarController = viewController as? UITabBarController {
                    tabBarController.localizedTabbars()
                }else if let navigationController = viewController as? UINavigationController {
                    // Working Soon
                }
            }
            
            resetToLocalizationKeys(view: subview)
        }
    }
}
extension UITabBarController{
    func localizedTabbars(){}
}
#endif
