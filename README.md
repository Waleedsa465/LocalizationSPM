# Localization_Swift

A Swift Package with localization utilities plus a grab-bag of UIKit/AppKit/SwiftUI helpers: an animated gradient/shimmer background, a SwiftUI loader and progress HUD, iOS/macOS toasts, a growing text view, proxy monitoring, color helpers, and common Foundation/UIKit/AppKit extensions.

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

## SwiftUI

### GradientBackgroundView

An animated gradient background with optional shimmer, breathing (pulse), and scale effects.

```swift
GradientBackgroundView(
    colors: [.blue, .purple],
    shimmerColors: [],
    startPoint: .leading,
    endPoint: .trailing,
    cornerRadius: 16,
    shimmer: true,
    breathing: true,
    scalingEffect: true
)
```

### Shimmer view modifier

Puts `GradientBackgroundView` behind any view (backed by the public `ShimmerEffectModifier`):

```swift
Text("Upgrade")
    .padding()
    .addShimmerAndBreathingEffect(colors: [.purple, .blue], cornerRadius: 20)
```

Optional parameters: `shimmerColors`, `startPoint`, `endPoint`, `cornerRadius`, `shimmer`, `breathing`, `scalingEffect`, `shimmerTimer`.

### Loader (`.loader`)

A pure SwiftUI loader driven by a `@State` flag. While it is showing, the content is disabled and a window-level blocker swallows all touches/clicks, including the navigation bar, toolbar, tab bar and swipe-back (iOS) and the titlebar/toolbar (macOS).

```swift
@State private var isLoading = false

ContentView()
    .loader(isLoading: $isLoading, message: "Loading…")
```

Optional parameters: `message`, `tint`, `dimOpacity`. On macOS, keyboard shortcuts and menu commands are not blocked.

### Progress HUD

An MBProgressHUD-style HUD for UIKit/AppKit views, plus a SwiftUI wrapper:

```swift
// UIKit / AppKit
ProgressHudUtility.shared.showHUD(on: view)
ProgressHudUtility.shared.hideHUD(view: view)

// SwiftUI
SomeView().progressHUD(isShowing: $isShowing)
```

Prefer `.loader(isLoading:)` when you also need to block interaction.

### Drop shadow

```swift
Text("Hi").dropShadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)   // SwiftUI View
someView.dropShadow(color: .black, opacity: 0.2, radius: 10)                  // UIView / NSView
```

### Hosting a SwiftUI view inside UIKit/AppKit

`PlatformView` (a `UIView` on iOS, `NSView` on macOS) gets a generic hosting helper and a gradient convenience:

```swift
// Host any SwiftUI view, optionally expanding its frame by `inset`
someView.addHostedView(MyCustomSwiftUIView(), inset: 8)

// Gradient background, inserted behind existing subviews
someView.embedGradientBackground(colors: [.blue, .purple])
```

## Colors

Cross-platform hex helpers for `Color`, `UIColor` and `NSColor`. Supported formats: `RGB`, `RRGGBB`, `RRGGBBAA` (with or without `#`). Invalid input falls back to clear.

```swift
Color(hex: "#FF8000")
Color(hex: "#FF8000CC")
Color(hex: "#FF8000", alpha: 0.5)    // alpha overrides the hex alpha
Color(r: 255, g: 128, b: 0)

PlatformColor(hex: "#FF8000")        // UIColor / NSColor
color.hexString                      // "#FF8000CC" (alpha included when < 1)
color.hex6                           // "#FF8000"
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
- **`URL`** — `truncatedFileName(maxLength:)`
- **`Bundle`** — `appVersion`, `buildNumber`, `fullVersion`
- **`Encodable`** — `toDictionary()`
- **`Array`** — `asyncCompactMap`
- **`Color`, `UIColor`, `NSColor`** — hex init and `hexString` / `hex6` (see Colors)
- **`PlatformImage` / `PlatformImageView`** — `UIImage`/`NSImage` and `UIImageView`/`NSImageView` type aliases with shared helpers (`resize`, `resizeMaintainingAspectRatio`, `pngRepresentation`, `savePngTo`)
- **`PlatformView` / `PlatformViewController`** — `UIView`/`NSView` and `UIViewController`/`NSViewController` type aliases, including animated child-view-controller embedding (`addChildViewControllerWithAnimation`, `addChildViewControllerWithOutAnimation`, `removeChildFromNavigation`)
- **`PlatformTableView`** — `reloadVisibleCurrentRows()`
- **`NSItemProvider`** — async image/data loading for drag & drop (`loadImage`, `loadDataSafely`)

macOS-only helper classes are also included: `DraggableImageView` + `QuickLookHandler` (drag-out + Quick Look preview for images), `NonClickableView`, and `NoArrowKeysCollectionView`.

## Requirements

- Xcode with Swift 6.0 toolchain
- iOS 15+ / macOS 12+
