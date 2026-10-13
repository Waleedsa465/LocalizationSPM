import Foundation
#if canImport(SwiftUI)
import SwiftUI
import Combine

@MainActor
public final class LocalizationObserver: ObservableObject {
    public static let shared = LocalizationObserver()
    
    @Published public private(set) var language: String = Localize.currentLanguage()
    private var cancellable: AnyCancellable?
    
    private init() {
        cancellable = NotificationCenter.default
            .publisher(for: Notification.Name(rawValue: LCLLanguageChangeNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.language = Localize.currentLanguage() }
    }
}

private struct LocalizedModifier: ViewModifier {
    @ObservedObject private var observer = LocalizationObserver.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: observer.language))
            .id(observer.language)
    }
}

public extension View {
    func observeLocalization() -> some View { modifier(LocalizedModifier()) }
}

public extension Text {
    init(localized key: String, tableName: String? = nil) {
        self.init(verbatim: key.localized(using: tableName))
    }
}
#endif
