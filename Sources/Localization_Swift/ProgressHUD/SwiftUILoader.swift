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
    
    struct Config: Equatable {
        var isBlocking = false
        var message: String?
        var dimOpacity: Double = 0.25
        var tint: Color = .accentColor
    }
    
    override func didMoveToWindow() { super.didMoveToWindow(); sync() }
    
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
        } else if let old = blocker {
            blocker = nil
            hosting = nil
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
#elseif os(macOS)
private final class WindowBlockerView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { self }
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseDown(with event: NSEvent) {}
    override func rightMouseDown(with event: NSEvent) {}
    override func otherMouseDown(with event: NSEvent) {}
    override func scrollWheel(with event: NSEvent) {}
}

private final class BlockerHostView: NSView {
    var config = Config() { didSet { sync() } }
    private var blocker: WindowBlockerView?
    private var hosting: NSHostingView<LoaderCard>?
    
    struct Config: Equatable {
        var isBlocking = false
        var message: String?
        var dimOpacity: Double = 0.25
        var tint: Color = .accentColor
    }
    
    override func viewDidMoveToWindow() { super.viewDidMoveToWindow(); sync() }
    
    private func sync() {
        if config.isBlocking, let container = window?.contentView {
            let card = LoaderCard(message: config.message, tint: config.tint)
            if let blocker {
                blocker.layer?.backgroundColor = NSColor.black.withAlphaComponent(config.dimOpacity).cgColor
                hosting?.rootView = card
                return
            }
            let view = WindowBlockerView(frame: container.bounds)
            view.autoresizingMask = [.width, .height]
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.black.withAlphaComponent(config.dimOpacity).cgColor
            let host = NSHostingView(rootView: card)
            host.frame = view.bounds
            host.autoresizingMask = [.width, .height]
            view.addSubview(host)
            view.alphaValue = 0
            container.addSubview(view, positioned: .above, relativeTo: nil)
            window?.makeFirstResponder(view)
            NSAnimationContext.runAnimationGroup { $0.duration = 0.2; view.animator().alphaValue = 1 }
            blocker = view
            hosting = host
        } else if let old = blocker {
            blocker = nil
            hosting = nil
            NSAnimationContext.runAnimationGroup({ $0.duration = 0.2; old.animator().alphaValue = 0 },
                                                 completionHandler: { MainActor.assumeIsolated { old.removeFromSuperview() } })
        }
    }
}

private struct WindowBlocker: NSViewRepresentable {
    let config: BlockerHostView.Config
    func makeNSView(context: Context) -> BlockerHostView { BlockerHostView() }
    func updateNSView(_ view: BlockerHostView, context: Context) { view.config = config }
    static func dismantleNSView(_ view: BlockerHostView, coordinator: ()) { view.config.isBlocking = false }
}
#endif

// MARK: - Modifier

public struct LoaderModifier: ViewModifier {
    @Binding var isLoading: Bool
    var message: String?
    var tint: Color
    var dimOpacity: Double
    
    public func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .background(
                WindowBlocker(config: .init(isBlocking: isLoading, message: message,
                                            dimOpacity: dimOpacity, tint: tint))
            )
    }
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
