import Foundation
import SwiftUI

// MARK: - NSColor (AppKit) Hex Support
#if canImport(AppKit)
import AppKit

public extension NSColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha: CGFloat
        if hexString.count == 8 {
            alpha = CGFloat((rgb & 0x0000_00FF)) / 255.0
        } else {
            alpha = 1.0
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#endif

// MARK: - UIColor (UIKit) Hex Support
#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init?(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        guard hexFormatted.count == 6 || hexFormatted.count == 8 else { return nil }
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        if hexFormatted.count == 6 {
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        } else {
            let red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            let blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            let alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    var hexString: String {
        return hexString(includeAlpha: true)
    }
    
    func hexString(includeAlpha: Bool = true) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        let a = Int(round(alpha * 255))
        
        if includeAlpha && alpha < 1.0 {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
    
    var hex6: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
#endif

// MARK: - SwiftUI Color Hex Support
public extension Color {
    init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, opacity: a)
    }
    
    init(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, opacity: a)
    }
    
    init(hex: String, alpha: Double = 1) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6 || hexString.count == 8 else {
            self.init(white: 0, opacity: alpha)
            return
        }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let red: Double
        let green: Double
        let blue: Double
        let opacity: Double
        if hexString.count == 8 {
            red = Double((rgb & 0xFF00_0000) >> 24) / 255
            green = Double((rgb & 0x00FF_0000) >> 16) / 255
            blue = Double((rgb & 0x0000_FF00) >> 8) / 255
            opacity = Double(rgb & 0x0000_00FF) / 255
        } else {
            red = Double((rgb & 0xFF0000) >> 16) / 255
            green = Double((rgb & 0x00FF00) >> 8) / 255
            blue = Double(rgb & 0x0000FF) / 255
            opacity = alpha
        }
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
