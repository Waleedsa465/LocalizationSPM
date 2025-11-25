# LocalizationSPM

[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

A Swift Package Manager (SPM) library for easy localization of your iOS app's UI. Automatically localizes view hierarchies by replacing text with localized strings.

## Features

- ✅ Reset view hierarchy to original English keys
- ✅ Set current language from UserDefaults or any string
- ✅ Automatically localize entire view hierarchy
- ✅ Supports UILabel, UIButton, UITextField, UITextView and more
- ✅ Lightweight and easy to integrate

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, select **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/Waleedsa465/LocalizationSPM.git`
3. Select the latest version and add to your target

## Usage

### Step 1: Reset to Original English Keys
```swift
LocalizationUtility.resetToLocalizationKeys(view: view)
```
Resets all localized text back to their original English localization keys.

### Step 2: Set Current Language
```swift
Localize.setCurrentLanguage(AppDefaults.shared.appLanguage)
```
Sets the current language. Use your stored language preference (e.g., from UserDefaults).

### Step 3: Localize View Hierarchy
```swift
LocalizationUtility.localizeViewHierarchy(view: view)
```
Automatically localizes the entire view hierarchy using the set language.

## Complete Example

```swift
// In your view controller or wherever you handle language change
func changeLanguage() {
    // 1. Reset to English keys first
    LocalizationUtility.resetToLocalizationKeys(view: view)
    
    // 2. Set the new language (stored in UserDefaults)
    Localize.setCurrentLanguage(AppDefaults.shared.appLanguage)
    
    // 3. Localize the entire view hierarchy
    LocalizationUtility.localizeViewHierarchy(view: view)
}
```

## Supported Views

The library automatically localizes:
- `UILabel` or `NSTextField`
- `UIButton` (title) or `NSButton`
- `UITextField` (placeholder)  or `NSTextField` (placeholder)
- `UITextView` not Suppourted Yet (working on future)
- `UICollectionView` or `NSCollectionView`(reload only) ---> just simply add .localized() after your cell label,button,textfield string
- Custom views with `text` or `title` properties

## Setup Requirements

1. **Localizable.strings** files in your project with keys matching your UI text
2. Store selected language in UserDefaults (e.g., `"en"`, `"es"`, `"fr"`, etc.)

### Example Localizable.strings (English)
```
"welcome_message" = "Welcome to our app!";
"login_button" = "Login";
```

### Example Localizable.strings (Spanish)
```
"welcome_message" = "¡Bienvenido a nuestra app!";
"login_button" = "Iniciar sesión";
```

## Language Change Trigger

Call the localization sequence whenever:
- User changes language in settings
- App launches (to restore saved language)
- Language preference updates from server

```swift
// Perfect for app launch or language change
override func viewDidLoad() {
    super.viewDidLoad()
    applyLocalization()
}

private func applyLocalization() {
    LocalizationUtility.resetToLocalizationKeys(view: self.view)
    Localize.setCurrentLanguage(AppDefaults.shared.appLanguage)
    LocalizationUtility.localizeViewHierarchy(view: self.view)
}
```

## Troubleshooting

**❌ Text not localizing?**
1. Ensure your `Localizable.strings` files have matching keys
2. Verify language code format (`"en"`, `"es"`, `"fr"`)
3. Check that `AppDefaults.shared.appLanguage` returns valid code

**❌ UI flickers during localization?**
The reset → set → localize sequence prevents flickering by showing English keys first.

## Contributing

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

MIT License

Copyright (c) 2025 Muhammad Waleed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

**Made with ❤️ for iOS and MacOS developers** 🚀
