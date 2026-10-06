import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
private final class WindowBlockerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { self }
}

private final class BlockerHostView: UIView {
    var isBlocking = false { didSet { sync() } }
    private var blocker: WindowBlockerView?

    override func didMoveToWindow() { super.didMoveToWindow(); sync() }

    private func sync() {
        if isBlocking, let window {
            guard blocker == nil else { return }
            let view = WindowBlockerView(frame: window.bounds)
            view.backgroundColor = .clear
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(view)
            blocker = view
        } else {
            blocker?.removeFromSuperview()
            blocker = nil
        }
    }
}

private struct WindowBlocker: UIViewRepresentable {
    let isBlocking: Bool
    func makeUIView(context: Context) -> BlockerHostView { BlockerHostView() }
    func updateUIView(_ view: BlockerHostView, context: Context) { view.isBlocking = isBlocking }
    static func dismantleUIView(_ view: BlockerHostView, coordinator: ()) { view.isBlocking = false }
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
    var isBlocking = false { didSet { sync() } }
    private var blocker: WindowBlockerView?

    override func viewDidMoveToWindow() { super.viewDidMoveToWindow(); sync() }

    private func sync() {
        if isBlocking, let frameView = window?.contentView?.superview {
            guard blocker == nil else { return }
            let view = WindowBlockerView(frame: frameView.bounds)
            view.autoresizingMask = [.width, .height]
            frameView.addSubview(view, positioned: .above, relativeTo: nil)
            window?.makeFirstResponder(view)
            blocker = view
        } else {
            blocker?.removeFromSuperview()
            blocker = nil
        }
    }
}

private struct WindowBlocker: NSViewRepresentable {
    let isBlocking: Bool
    func makeNSView(context: Context) -> BlockerHostView { BlockerHostView() }
    func updateNSView(_ view: BlockerHostView, context: Context) { view.isBlocking = isBlocking }
    static func dismantleNSView(_ view: BlockerHostView, coordinator: ()) { view.isBlocking = false }
}
#endif


public struct LoaderModifier: ViewModifier {
    @Binding var isLoading: Bool
    var message: String?
    var tint: Color
    var dimOpacity: Double

    public func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .background(WindowBlocker(isBlocking: isLoading))
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(dimOpacity)
                            .contentShape(Rectangle())
                            .onTapGesture {}

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
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isLoading)
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
