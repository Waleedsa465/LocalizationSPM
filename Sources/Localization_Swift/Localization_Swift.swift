// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public extension String {
    
    func localized(using tableName: String?) -> String {
        return localized(using: tableName, in: .main)
    }
    
    func localizedFormat(arguments: CVarArg..., using tableName: String?) -> String {
        return String(format: localized(using: tableName), arguments: arguments)
    }
    func localizedPlural(argument: CVarArg, using tableName: String?) -> String {
        return NSString.localizedStringWithFormat(localized(using: tableName) as NSString, argument) as String
    }
    func localized(using tableName: String?, in bundle: Bundle?) -> String {
            let bundle: Bundle = bundle ?? .main
            if let path = bundle.path(forResource: Localize.currentLanguage(), ofType: "lproj"),
                let bundle = Bundle(path: path) {
                return bundle.localizedString(forKey: self, value: nil, table: tableName)
            }
            else if let path = bundle.path(forResource: LCLBaseBundle, ofType: "lproj"),
                let bundle = Bundle(path: path) {
                return bundle.localizedString(forKey: self, value: nil, table: tableName)
            }
            return self
        }
        func localizedFormat(arguments: CVarArg..., using tableName: String?, in bundle: Bundle?) -> String {
            return String(format: localized(using: tableName, in: bundle), arguments: arguments)
        }
        func localizedPlural(argument: CVarArg, using tableName: String?, in bundle: Bundle?) -> String {
            return NSString.localizedStringWithFormat(localized(using: tableName, in: bundle) as NSString, argument) as String
        }
    func localized(in bundle: Bundle?) -> String {
        return localized(using: nil, in: bundle)
    }
    func localizedFormat(arguments: CVarArg..., in bundle: Bundle?) -> String {
        return String(format: localized(in: bundle), arguments: arguments)
    }
    func localizedPlural(argument: CVarArg, in bundle: Bundle?) -> String {
        return NSString.localizedStringWithFormat(localized(in: bundle) as NSString, argument) as String
    }
}
let LCLCurrentLanguageKey = "LCLCurrentLanguageKey"
let LCLDefaultLanguage = "en"
let LCLBaseBundle = "Base"
public let LCLLanguageChangeNotification = "LCLLanguageChangeNotification"
public func Localized(_ string: String) -> String {
    return string.localized()
}
public func Localized(_ string: String, arguments: CVarArg...) -> String {
    return String(format: string.localized(), arguments: arguments)
}
public func LocalizedPlural(_ string: String, argument: CVarArg) -> String {
    return string.localizedPlural(argument)
}
public extension String {
    func localized() -> String {
        return localized(using: nil, in: .main)
    }
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized(), arguments: arguments)
    }
    
    /**
     Swift 2 friendly plural localization syntax with a format argument
     
     - parameter argument: Argument to determine pluralisation
     
     - returns: Pluralized localized string.
     */
    func localizedPlural(_ argument: CVarArg) -> String {
        return NSString.localizedStringWithFormat(localized() as NSString, argument) as String
    }

    /**
     Add comment for NSLocalizedString
     - Returns: The localized string.
    */
    func commented(_ argument: String) -> String {
        return self
    }
}

open class Localize: NSObject {
    open class func availableLanguages(_ excludeBase: Bool = false) -> [String] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.firstIndex(of: "Base") , excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    open class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: LCLCurrentLanguageKey) as? String {
            return currentLanguage
        }
        return defaultLanguage()
    }
    open class func setCurrentLanguage(_ language: String) {
        let selectedLanguage = availableLanguages().contains(language) ? language : defaultLanguage()
        if (selectedLanguage != currentLanguage()){
            UserDefaults.standard.set(selectedLanguage, forKey: LCLCurrentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        }
    }
    open class func defaultLanguage() -> String {
        var defaultLanguage: String = String()
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return LCLDefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if (availableLanguages.contains(preferredLanguage)) {
            defaultLanguage = preferredLanguage
        }
        else {
            defaultLanguage = LCLDefaultLanguage
        }
        return defaultLanguage
    }
    open class func resetCurrentLanguageToDefault() {
        setCurrentLanguage(self.defaultLanguage())
    }
    open class func displayNameForLanguage(_ language: String) -> String {
        let locale : NSLocale = NSLocale(localeIdentifier: currentLanguage())
        if let displayName = locale.displayName(forKey: NSLocale.Key.identifier, value: language) {
            return displayName
        }
        return String()
    }
}

//MARK: - Usage Functions
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

