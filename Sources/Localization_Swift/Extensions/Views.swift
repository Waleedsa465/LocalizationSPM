import SwiftUI
import ObjectiveC

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Drop Shadow Support
private struct ShadowConfig {
    var color: Color
    var opacity: Float
    var darkOpacity: Float?
    var radius: CGFloat
    var offset: CGSize
    var cornerRadius: CGFloat?
}

private final class ShadowConfigBox {
    let value: ShadowConfig
    init(_ value: ShadowConfig) { self.value = value }
}

nonisolated(unsafe) private var shadowConfigKey: UInt8 = 0
nonisolated(unsafe) private var shadowObserverKey: UInt8 = 0

#if os(iOS)
private final class ShadowTraitObserverView: UIView {
    private let onChange: () -> Void

    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { nil }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previous) {
            onChange()
        }
    }
}
#endif

// MARK: - Uikit + AppKit Views Extension
public extension PlatformView {
    
    @discardableResult
    func dropShadow(
        color: Color = .black,
        opacity: Float = 0.2,
        darkOpacity: Float? = nil,
        radius: CGFloat = 10,
        offset: CGSize = CGSize(width: 0, height: 5),
        cornerRadius: CGFloat? = nil
    ) -> Self {
        let config = ShadowConfig(
            color: color,
            opacity: opacity,
            darkOpacity: darkOpacity,
            radius: radius,
            offset: offset,
            cornerRadius: cornerRadius
        )
        objc_setAssociatedObject(self, &shadowConfigKey, ShadowConfigBox(config), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        applyStoredShadow()
        observeAppearanceForShadowIfNeeded()
        return self
    }

    fileprivate func applyStoredShadow() {
        guard let config = (objc_getAssociatedObject(self, &shadowConfigKey) as? ShadowConfigBox)?.value else { return }
#if os(iOS)
        let isDark = traitCollection.userInterfaceStyle == .dark
        layer.shadowColor = UIColor(config.color).resolvedColor(with: traitCollection).cgColor
        layer.shadowOpacity = isDark ? (config.darkOpacity ?? config.opacity) : config.opacity
        layer.shadowRadius = config.radius
        layer.shadowOffset = config.offset
        layer.masksToBounds = false
        if let cornerRadius = config.cornerRadius {
            layer.cornerRadius = cornerRadius
        }
#elseif os(macOS)
        wantsLayer = true
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        effectiveAppearance.performAsCurrentDrawingAppearance {
            layer?.shadowColor = NSColor(config.color).cgColor
        }
        layer?.shadowOpacity = isDark ? (config.darkOpacity ?? config.opacity) : config.opacity
        layer?.shadowRadius = config.radius
        layer?.shadowOffset = CGSize(width: config.offset.width, height: -config.offset.height)
        layer?.masksToBounds = false
        if let cornerRadius = config.cornerRadius {
            layer?.cornerRadius = cornerRadius
        }
#endif
    }

    private func observeAppearanceForShadowIfNeeded() {
        guard objc_getAssociatedObject(self, &shadowObserverKey) == nil else { return }
#if os(iOS)
        let observer = ShadowTraitObserverView { [weak self] in self?.applyStoredShadow() }
        addSubview(observer)
        objc_setAssociatedObject(self, &shadowObserverKey, observer, .OBJC_ASSOCIATION_ASSIGN)
#elseif os(macOS)
        let token = observe(\.effectiveAppearance, options: [.new]) { view, _ in
            MainActor.assumeIsolated { view.applyStoredShadow() }
        }
        objc_setAssociatedObject(self, &shadowObserverKey, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#endif
    }

    @discardableResult
    func addHostedView<Content: View>(_ swiftUIView: Content, inset: CGFloat = 0) -> PlatformView {
#if os(iOS)
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        guard let hostedView = hostingController.view else { return self }
        
#elseif os(macOS)
        let hostingView = NSHostingView(rootView: swiftUIView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.layer?.backgroundColor = .clear
        addSubview(hostingView)
        let hostedView = hostingView
#endif

        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -inset),
            hostedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset),
            hostedView.topAnchor.constraint(equalTo: topAnchor, constant: -inset),
            hostedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset)
        ])

        return hostedView
    }
    
    @discardableResult
    func embedGradientBackground(
        colors: [Color],
        shimmerColors: [Color] = [.white.opacity(0.35),.white.opacity(0.0),.white.opacity(0.18)],
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing,
        cornerRadius: CGFloat = 12,
        shimmer: Bool = true,
        breathing: Bool = true,
        scalingEffect: Bool = true,
        shimmerTimer: TimeInterval = 2.4,
        inOutTimer: TimeInterval = 1.08
    ) -> PlatformView {
        let rootView = GradientBackgroundView(
            colors: colors,
            shimmerColors: shimmerColors,
            startPoint: startPoint,
            endPoint: endPoint,
            cornerRadius: cornerRadius,
            shimmer: shimmer,
            breathing: breathing,
            scalingEffect: scalingEffect,
            shimmerTimer: shimmerTimer,
            inOutTimer: inOutTimer
        )
        
#if os(iOS)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(hostingController.view, at: 0)
        guard let hostedView = hostingController.view else { return self }
        
#elseif os(macOS)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.layer?.backgroundColor = .clear
        addSubview(hostingView, positioned: .below, relativeTo: subviews.first)
        let hostedView = hostingView
#endif
        
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        return hostedView
    }
}

// MARK: - Swift Ui Views Extension
public extension View {
    func addShimmerAndBreathingEffect(
        colors: [Color],
        shimmerColors: [Color] = [.white.opacity(0.35),.white.opacity(0.0),.white.opacity(0.18)],
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing,
        cornerRadius: CGFloat = 12,
        shimmer: Bool = true,
        breathing: Bool = true,
        scalingEffect: Bool = true,
        shimmerTimer: TimeInterval = 2.4,
        inOutTimer: TimeInterval = 1.08
    ) -> some View {
        modifier(ShimmerEffectModifier(
            colors: colors,
            shimmerColors: shimmerColors,
            startPoint: startPoint,
            endPoint: endPoint,
            cornerRadius: cornerRadius,
            shimmer: shimmer,
            breathing: breathing,
            scalingEffect: scalingEffect,
            shimmerTimer: shimmerTimer,
            inOutTimer: inOutTimer
        ))
    }
    func dropShadow(
        color: Color = .black.opacity(0.2),
        radius: CGFloat = 10,
        x: CGFloat = 0,
        y: CGFloat = 5
    ) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }
}
