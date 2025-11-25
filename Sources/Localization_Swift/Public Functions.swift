//
//  File.swift
//  Localization_Swift
//
//  Created by Macbook Pro M1 on 25/11/2025.
//

import Foundation

public func Localized(_ string: String) -> String {
    return string.localized()
}
public func Localized(_ string: String, arguments: CVarArg...) -> String {
    return String(format: string.localized(), arguments: arguments)
}
public func LocalizedPlural(_ string: String, argument: CVarArg) -> String {
    return string.localizedPlural(argument)
}
