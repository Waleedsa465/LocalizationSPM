//
//  NonClickableView.swift
//  Localization_Swift
//
//  Created by Personal on 25/01/2026.
//

#if os(macOS)
import Cocoa

// MARK: - Make View Return 
class NonClickableView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(nil)
    }
}
#endif
