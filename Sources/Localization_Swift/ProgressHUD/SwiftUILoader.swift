import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Loader card
private struct LoaderCard: View {
    var message: String?
    var tint: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(tint)
                .scaleEffect(1.3)
            if let message, !message.isEmpty {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if os(iOS)
private final class WindowBlockerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { self }
}

private final class BlockerHostView: UIView {
    var config = Config() { didSet { sync() } }
    private var blocker: WindowBlockerView?
    private var hosting: UIHostingController<LoaderCard>?
    
    #if targetEnvironment(macCatalyst)
    private var lockedBars: [UINavigationBar] = []
    private var lockedToolbarItems: [NSToolbarItem] = []
    #endif
    
    struct Config: Equatable {
        var isBlocking = false
        var message: String?
        var dimOpacity: Double = 0.25
        var tint: Color = .accentColor
    }
    
    override func didMoveToWindow() { super.didMoveToWindow(); sync() }
    
    #if targetEnvironment(macCatalyst)
    private func navigationBars(in view: UIView) -> [UINavigationBar] {
        var result: [UINavigationBar] = []
        if let bar = view as? UINavigationBar { result.append(bar) }
        for sub in view.subviews { result += navigationBars(in: sub) }
        return result
    }
    
    private func lockChrome(in window: UIWindow) {
        guard lockedBars.isEmpty, lockedToolbarItems.isEmpty else { return }
        lockedBars = navigationBars(in: window).filter { $0.isUserInteractionEnabled }
        lockedBars.forEach { $0.isUserInteractionEnabled = false }
        if let items = window.windowScene?.titlebar?.toolbar?.items {
            lockedToolbarItems = items.filter { $0.isEnabled }
            lockedToolbarItems.forEach { $0.isEnabled = false }
        }
    }
    
    private func unlockChrome() {
        lockedBars.forEach { $0.isUserInteractionEnabled = true }
        lockedToolbarItems.forEach { $0.isEnabled = true }
        lockedBars = []
        lockedToolbarItems = []
    }
    #endif
    
    private func sync() {
        if config.isBlocking, let window {
            let card = LoaderCard(message: config.message, tint: config.tint)
            if let blocker {
                blocker.backgroundColor = UIColor.black.withAlphaComponent(config.dimOpacity)
                hosting?.rootView = card
                return
            }
            let view = WindowBlockerView(frame: window.bounds)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.backgroundColor = UIColor.black.withAlphaComponent(config.dimOpacity)
            let host = UIHostingController(rootView: card)
            host.view.backgroundColor = .clear
            host.view.frame = view.bounds
            host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(host.view)
            view.alpha = 0
            window.addSubview(view)
            UIView.animate(withDuration: 0.2) { view.alpha = 1 }
            blocker = view
            hosting = host
            #if targetEnvironment(macCatalyst)
            lockChrome(in: window)
            #endif
        } else if let old = blocker {
            blocker = nil
            hosting = nil
            #if targetEnvironment(macCatalyst)
            unlockChrome()
            #endif
            UIView.animate(withDuration: 0.2, animations: { old.alpha = 0 }) { _ in old.removeFromSuperview() }
        }
    }
}

private struct WindowBlocker: UIViewRepresentable {
    let config: BlockerHostView.Config
    func makeUIView(context: Context) -> BlockerHostView { BlockerHostView() }
    func updateUIView(_ view: BlockerHostView, context: Context) { view.config = config }
    static func dismantleUIView(_ view: BlockerHostView, coordinator: ()) { view.config.isBlocking = false }
}
#endif

public struct LoaderModifier: ViewModifier {
    @Binding var isLoading: Bool
    var message: String?
    var tint: Color
    var dimOpacity: Double
    
    #if os(iOS)
    public func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .background(
                WindowBlocker(config: .init(isBlocking: isLoading, message: message,
                                            dimOpacity: dimOpacity, tint: tint))
            )
    }
    #else
    public func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(dimOpacity)
                        LoaderCard(message: message, tint: tint)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {}
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
    #endif
}

public extension View {
    func loader(
        isLoading: Binding<Bool>,
        message: String? = nil,
        tint: Color = .accentColor,
        dimOpacity: Double = 0.25
    ) -> some View {
        modifier(LoaderModifier(isLoading: isLoading, message: message, tint: tint, dimOpacity: dimOpacity))
    }
}
