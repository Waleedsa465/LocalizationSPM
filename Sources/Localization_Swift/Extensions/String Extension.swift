import Foundation

public extension String {
    func localized() -> String {
        localized(using: nil, in: .main)
    }
    func localizedFormat(_ arguments: CVarArg...) -> String {
        String(format: localized(), arguments: arguments)
    }
    func localizedPlural(_ argument: CVarArg) -> String {
        NSString.localizedStringWithFormat(localized() as NSString, argument) as String
    }
    func commented(_ argument: String) -> String {
        self
    }
    func localized(using tableName: String?) -> String {
        localized(using: tableName, in: .main)
    }
    
    func localizedFormat(arguments: CVarArg..., using tableName: String?) -> String {
        String(format: localized(using: tableName), arguments: arguments)
    }
    func localizedPlural(argument: CVarArg, using tableName: String?) -> String {
        NSString.localizedStringWithFormat(localized(using: tableName) as NSString, argument) as String
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
        String(format: localized(using: tableName, in: bundle), arguments: arguments)
    }
    func localizedPlural(argument: CVarArg, using tableName: String?, in bundle: Bundle?) -> String {
        NSString.localizedStringWithFormat(localized(using: tableName, in: bundle) as NSString, argument) as String
    }
    func localized(in bundle: Bundle?) -> String {
        localized(using: nil, in: bundle)
    }
    func localizedFormat(arguments: CVarArg..., in bundle: Bundle?) -> String {
        String(format: localized(in: bundle), arguments: arguments)
    }
    func localizedPlural(argument: CVarArg, in bundle: Bundle?) -> String {
        NSString.localizedStringWithFormat(localized(in: bundle) as NSString, argument) as String
    }
}
