import Foundation

public extension URL {
    
    func truncatedFileName(maxLength: Int = 16) -> String {
        let fullName = lastPathComponent
        
        guard fullName.count > maxLength else {
            return fullName
        }
        
        let ext = pathExtension
        let nameWithoutExt = deletingPathExtension().lastPathComponent
        let suffix = ext.isEmpty ? "" : ".\(ext)"
        let reserved = "...".count + suffix.count
        let keepLength = max(maxLength - reserved, 1)
        
        let truncatedBase = String(nameWithoutExt.prefix(keepLength))
        
        return "\(truncatedBase)...\(suffix)"
    }
}
