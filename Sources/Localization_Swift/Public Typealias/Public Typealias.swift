#if os(iOS)
import UIKit
import SwiftUI

public typealias PlatformImageView = UIImageView
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
public typealias PlatformTableView = UITableView
public typealias PlatformViewController = UIViewController
public typealias PlatformView = UIView
public typealias PlatformViewRepresentable = UIViewRepresentable

#elseif os(macOS)
import AppKit
import SwiftUI

public typealias PlatformImageView = NSImageView
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
public typealias PlatformTableView = NSTableView
public typealias PlatformViewController = NSViewController
public typealias PlatformView = NSView
public typealias PlatformViewRepresentable = NSViewRepresentable

#endif
