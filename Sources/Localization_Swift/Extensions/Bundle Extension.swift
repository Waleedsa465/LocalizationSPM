import Foundation

public extension Bundle {
    
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    
    var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}
