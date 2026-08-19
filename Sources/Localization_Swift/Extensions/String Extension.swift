import Foundation

public extension String {
    
    // MARK: - Variables
    
    var cleanedJsonString: String {
        replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    // MARK: - Functions
    func localized() -> String { localized(using: nil, in: .main) }
    
    func commented(_ argument: String) -> String { self }
    
    func localizedFormat(_ arguments: CVarArg...) -> String { String(format: localized(), arguments: arguments) }
    
    func localizedPlural(_ argument: CVarArg) -> String {
        NSString.localizedStringWithFormat(localized() as NSString, argument) as String
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
    func truncateName(maxLength: Int = 16) -> String {
        guard count > maxLength else { return self }
        let reserved = "...".count
        let keepLength = max(maxLength - reserved, 1)
        let truncated = String(prefix(keepLength))
        return "\(truncated)..."
    }
    func extractBase64() -> String {
        guard let range = self.range(of: "base64,") else {
            return self
        }
        return String(self[range.upperBound...])
    }
    func chunked(by size: Int) -> [String] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
    func convertHtml() -> NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    NSAttributedString.DocumentReadingOptionKey.documentType:
                        NSAttributedString.DocumentType.html,
                    NSAttributedString.DocumentReadingOptionKey
                        .characterEncoding: String.Encoding.utf8.rawValue,
                ], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}
