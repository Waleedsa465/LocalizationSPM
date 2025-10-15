
import Foundation

public extension String {
    
    func localized(in bundle: Bundle?) -> String {
        return localized(using: nil, in: bundle)
    }
    func localizedFormat(arguments: CVarArg..., in bundle: Bundle?) -> String {
        return String(format: localized(in: bundle), arguments: arguments)
    }
    func localizedPlural(argument: CVarArg, in bundle: Bundle?) -> String {
        return NSString.localizedStringWithFormat(localized(in: bundle) as NSString, argument) as String
    }
   //
}
