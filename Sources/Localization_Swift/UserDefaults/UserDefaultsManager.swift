//
//  UserDefaultsManager.swift
//  Localization_Swift
//
//  Created by Macbook Pro M1 on 19/12/2025.
//


import Foundation

class UserDefaultsManager {
    
    // Key for storing the English string array
    private static let englishStringsKey = "englishStringsArray"
    
    /// Saves an array of English strings to UserDefaults
    /// - Parameter strings: Array of English strings to save
    /// - Returns: True if save was successful, false otherwise
    static func saveEnglishStrings(_ strings: [String]) -> Bool {
        guard !strings.isEmpty else {
            UserDefaults.standard.removeObject(forKey: englishStringsKey)
            return true
        }
        
        // Validate that strings are English (basic ASCII check)
        let validStrings = strings.filter { isValidEnglishString($0) }
        
        if validStrings.count != strings.count {
            print("Warning: Some strings were filtered out as non-English")
        }
        
        UserDefaults.standard.set(validStrings, forKey: englishStringsKey)
        UserDefaults.standard.synchronize()
        return true
    }
    
    /// Retrieves the saved English strings from UserDefaults
    /// - Returns: Array of saved English strings, empty array if none found
    static func getEnglishStrings() -> [String] {
        return UserDefaults.standard.array(forKey: englishStringsKey) as? [String] ?? []
    }
    
    /// Clears the saved English strings
    static func clearEnglishStrings() {
        UserDefaults.standard.removeObject(forKey: englishStringsKey)
    }
    
    /// Validates if a string appears to be English (basic ASCII check)
    private static func isValidEnglishString(_ string: String) -> Bool {
        let englishCharacterSet = CharacterSet.alphanumerics.union(.whitespacesAndNewlines)
            .union(CharacterSet(charactersIn: ".,!?;:'\"-()[]{}@#$%^&*+=/|\\<>"))
        
        return string.rangeOfCharacter(from: englishCharacterSet.inverted) == nil
    }
}

//// Usage example
//let englishWords = ["Hello", "World", "Apple", "Banana", "Computer"]
//UserDefaultsManager.saveEnglishStrings(englishWords)
//
//let savedWords = UserDefaultsManager.getEnglishStrings()
//print(savedWords) // ["Hello", "World", "Apple", "Banana", "Computer"]
