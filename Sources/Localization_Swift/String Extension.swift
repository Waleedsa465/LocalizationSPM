//
//  File.swift
//  Localization_Swift
//
//  Created by Macbook Pro M1 on 25/11/2025.
//

import Foundation

public extension String {
    func localized() -> String {
        return localized(using: nil, in: .main)
    }
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized(), arguments: arguments)
    }
    func localizedPlural(_ argument: CVarArg) -> String {
        return NSString.localizedStringWithFormat(localized() as NSString, argument) as String
    }
    func commented(_ argument: String) -> String {
        return self
    }
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
