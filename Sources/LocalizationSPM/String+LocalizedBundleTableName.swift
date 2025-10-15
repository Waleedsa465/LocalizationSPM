
import Foundation

/// bundle & tableName friendly extension
public extension String {
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
 //
}
