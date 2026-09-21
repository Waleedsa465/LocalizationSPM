# Localization_Swift

A Swift Package with localization utilities plus a grab-bag of UIKit/AppKit/SwiftUI helpers: gradient & shadow background views, iOS/macOS toasts, a growing text view, proxy monitoring, and common Foundation/UIKit/AppKit extensions.

- **Platforms:** iOS 15+, macOS 12+
- **Swift tools version:** 6.0

## Installation

### Swift Package Manager

In Xcode: **File ▸ Add Package Dependencies…** and paste the repository URL, or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "<repository-url>", from: "1.0.0")
]
```

Then add `"Localization_Swift"` to your target's dependencies.

```swift
import Localization_Swift
```

## Localization

### Setting up language files

Add an `.lproj` folder per language (e.g. `en.lproj/Localizable.strings`, `fr.lproj/Localizable.strings`) to your app target, same as standard iOS/macOS localization.

### Reading localized strings

```swift
Localized("welcome_message")
Localized("greeting_format", arguments: userName)
LocalizedPlural("items_count", argument: itemCount)
```

Or via the `String` extension directly:

```swift
"welcome_message".localized()
"greeting_format".localizedFormat(userName)
"items_count".localizedPlural(itemCount)

// Custom table / bundle
"welcome_message".localized(using: "CustomTable", in: myBundle)
```

### Switching the current language at runtime

```swift
Localize.availableLanguages()          // ["en", "fr", "es", ...]
Localize.currentLanguage()             // "en"
Localize.setCurrentLanguage("fr")      // posts LCLLanguageChangeNotification
Localize.defaultLanguage()
Localize.displayNameForLanguage("fr")  // "French"
Localize.resetCurrentLanguageToDefault()
```

Observe language changes:

```swift
NotificationCenter.default.addObserver(
    forName: Notification.Name(LCLLanguageChangeNotification),
    object: nil,
    queue: .main
) { _ in
    // reload localized UI
}
```

### Localizing a whole view hierarchy (iOS)

Tag views with a localization key using `accessibilityIdentifier`/`restorationIdentifier` conventions expected by `LocalizationUtility`, then:

```swift
LocalizationUtility.localizeViewHierarchy(view: self.view)
LocalizationUtility.resetToLocalizationKeys(view: self.view)
```

## SwiftUI background views

Both views expose fully `public` properties so you can configure or extend them freely from your own app target.

### GradientBackgroundView

An animated gradient background with optional shimmer, breathing (pulse), and scale effects.

```swift
GradientBackgroundView(
    colors: [.blue, .purple],
    startPoint: .leading,
    endPoint: .trailing,
    cornerRadius: 16,
    shimmer: true,
    breathing: true,
    scalingEffect: true
)
```

### ShadowView

A filled rounded rectangle with a configurable drop shadow. Its `shadowInset` (`radius + max(|offset.x|, |offset.y|)`) reports how much extra space the shadow needs so it isn't clipped when the view is inset exactly to its content's edges.

```swift
ShadowView(
    fillColor: .white,
    shadowColor: .black,
    cornerRadius: 16,
    radius: 12,
    offset: CGSize(width: 0, height: 4),
    opacity: 0.35
)
```

### Hosting a SwiftUI view inside UIKit/AppKit

`PlatformView` (a `UIView` on iOS, `NSView` on macOS) gets a generic hosting helper plus two ready-made convenience wrappers:

```swift
// Host any SwiftUI view, optionally expanding its frame beyond `self`'s
// bounds by `inset` (useful for content like shadows that draws outside
// its own layout frame).
someView.addHostedView(MyCustomSwiftUIView(), inset: 8)

// Gradient background, inserted behind existing subviews
someView.embedGradientBackground(colors: [.blue, .purple])

// Drop-shadow background (inset is computed for you)
someView.embedShadowBackground(fillColor: .white, shadowColor: .black)
```

## Toasts

### iOS

```swift
Toast.text("Saved!", subtitle: "Your changes were synced")
    .show(after: 0)

Toast.default(
    image: UIImage(systemName: "checkmark.circle")!,
    title: "Done"
)
.show(haptic: .success)
```

Toasts queue automatically and support swipe-to-dismiss, tap-to-dismiss, and custom `ToastConfiguration` / `ToastViewConfiguration` (direction, animation, duration, colors, corner radius, etc.).

### macOS

```swift
let toastController = ToastWindowController()
toastController.showToast(
    message: "Saved!",
    icon: Image(systemName: "checkmark.circle"),
    duration: 3,
    position: .bottomCenter(100),
    textColor: .white,
    viewBackGroundColor: .black
)
```

## GrowingTextView

An auto-growing text input, available on both platforms.

```swift
// iOS
let textView = GrowingTextView()
textView.growingDelegate = self
textView.placeholder = "Type a message..."

// macOS
let scrollView = GrowingTextScrollView()
```

## Proxy monitoring (macOS)

```swift
let monitor = ProxyMonitor()
monitor.startMonitoringProxySettings()
monitor.isProxyEnabled()
monitor.stopMonitoringProxySettings()
```

## Foundation / UIKit / AppKit extensions

A selection of the included extensions:

- **`String`** — `localized()`, `localizedFormat(_:)`, `localizedPlural(_:)`, `truncateName(maxLength:)`, `chunked(by:)`, `convertHtml()`, `extractBase64()`, `cleanedJsonString`
- **`Array` / `Sequence`** — convenience helpers for common collection operations
- **`URL`, `Bundle`, `Encodable`** — small utility helpers
- **`Color`, `UIColor`, `NSColor`** — cross-platform color helpers
- **`PlatformImage` / `PlatformImageView`** — `UIImage`/`NSImage` and `UIImageView`/`NSImageView` type aliases with shared helpers
- **`PlatformView` / `PlatformViewController`** — `UIView`/`NSView` and `UIViewController`/`NSViewController` type aliases, including animated child-view-controller embedding (`addChildViewControllerWithAnimation`, `removeChildFromNavigation`)
- **`PlatformTableView`, `NSItemProvider`** — table view and drag/drop helpers

macOS-only helper classes are also included: `DraggableImageView` + `QuickLookHandler` (drag-out + Quick Look preview for images), `NonClickableView`, and `NoArrowKeysCollectionView`.

## Requirements

- Xcode with Swift 6.0 toolchain
- iOS 15+ / macOS 12+
