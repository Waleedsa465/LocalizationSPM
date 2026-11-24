# Localization_Swift

A Swift Package with runtime localization utilities plus a grab-bag of UIKit/AppKit/SwiftUI helpers for iOS and macOS.

## What's inside

| Area | Highlights | iOS | macOS |
|---|---|:-:|:-:|
| **Localization** | `Localized()`, `String.localized()`, runtime language switching, view-hierarchy localization, SwiftUI live refresh (`observeLocalization()`) | ✅ | ✅ |
| **Before/After slider** | `BeforeAfterSliderView` with draggable divider and configurable badge positions (`.bottom`, `.top`, `.custom`) | ✅ | ✅ |
| **Gradient & shimmer** | `GradientBackgroundView`, `addShimmerAndBreathingEffect` | ✅ | ✅ |
| **Loader / HUD** | `.loader(isLoading:)` interaction-blocking loader, `ProgressHudUtility`, `.progressHUD` | ✅ | ✅ |
| **Toasts** | Queued toast system (iOS), `ToastWindowController` (macOS) | ✅ | ✅ |
| **GrowingTextView** | Auto-growing text input with placeholder | ✅ | ✅ |
| **Network monitoring** | `NetworkManager` (Wi-Fi / Ethernet / other / offline + notification) | ✅ | ✅ |
| **Proxy monitoring** | `ProxyMonitor` | – | ✅ |
| **Colors** | Hex init / `hexString` for `Color`, `UIColor`, `NSColor` | ✅ | ✅ |
| **Drop shadow & hosting** | `dropShadow`, `addHostedView`, `embedGradientBackground` | ✅ | ✅ |
| **Cross-platform aliases** | `PlatformImage`, `PlatformColor`, `PlatformView`, … | ✅ | ✅ |
| **Extensions** | `String`, `Array`, `URL`, `Bundle`, `Encodable`, `PlatformImage`, `NSItemProvider`, view controllers, table views | ✅ | ✅ |
| **macOS helpers** | `DraggableImageView` + Quick Look, `NonClickableView`, `NoArrowKeysCollectionView` | – | ✅ |

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

### SwiftUI live language refresh

```swift
ContentView()
    .observeLocalization()          // re-renders when the language changes

Text(localized: "welcome_message")  // Text initializer using the current language
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

### BeforeAfterSliderView

A draggable before/after image comparison, on both iOS and macOS. Pass `UIImage` on iOS and `NSImage` on macOS (both are `PlatformImage`).

```swift
BeforeAfterSliderView(beforeImage: before, afterImage: after)
    .frame(height: 300)
```

All parameters except the two images are optional:

| Parameter | Default | Description |
|---|---|---|
| `beforeTitle` / `afterTitle` | `"Before".localized()` / `"After".localized()` | Badge text |
| `initialPosition` | `0.5` | Starting divider position, `0...1` |
| `cornerRadius` | `24` | Corner radius of the whole view |
| `badgeColor` | `.black.opacity(0.55)` | Badge background |
| `badgePosition` | `.bottom` | Where the badges sit (see below) |

#### Badge position (`BeforeAfterBadgePosition`)

```swift
// Bottom corners (default): Before bottom-left, After bottom-right
BeforeAfterSliderView(beforeImage: before, afterImage: after, badgePosition: .bottom)

// Top corners: Before top-left, After top-right
BeforeAfterSliderView(beforeImage: before, afterImage: after, badgePosition: .top)

// Custom
BeforeAfterSliderView(
    beforeImage: before,
    afterImage: after,
    badgePosition: .custom(
        before: UnitPoint(x: 0.2, y: 0.5),
        after: UnitPoint(x: 0.8, y: 0.5)
    )
)
```

For `.custom(before:after:)` you provide **two `UnitPoint`s**, one for each badge. Each point is where that badge's **center** is placed, relative to the view's size:

- `x`: `0` = left edge, `1` = right edge
- `y`: `0` = top edge, `1` = bottom edge
- e.g. `UnitPoint(x: 0.5, y: 0.1)` = horizontally centered, near the top. `.center`, `.top`, `.bottomLeading` etc. also work.

Because the point is the badge's center, keep values away from `0`/`1` (e.g. `0.1…0.9`) so the badge isn't clipped by the edge.

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

## Network monitoring

```swift
NetworkManager.shared.start()

NetworkManager.shared.isConnected    // Bool
NetworkManager.shared.status         // .wifi, .ethernet, .other, .disconnected
NetworkManager.shared.isExpensive    // cellular / hotspot

NotificationCenter.default.addObserver(
    forName: .networkStatusChanged, object: nil, queue: .main
) { _ in /* react to connectivity change */ }
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
