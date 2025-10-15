
import Foundation

/// tableName friendly extension
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
    //
}
