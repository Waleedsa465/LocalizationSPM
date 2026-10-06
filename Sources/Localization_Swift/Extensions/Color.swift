import Foundation
import SwiftUI

public extension PlatformColor {
    
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6 || hexString.count == 8,
              let rgb = UInt64(hexString, radix: 16) else {
            self.init(white: 0, alpha: 1)
            return
        }
        let red, green, blue, alpha: CGFloat
        if hexString.count == 8 {
            red   = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
            blue  = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x0000_00FF) / 255.0
        } else {
            red   = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue  = CGFloat(rgb & 0x0000FF) / 255.0
            alpha = 1.0
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


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
