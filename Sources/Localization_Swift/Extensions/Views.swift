import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension View {
    func dropShadow(
        color: Color = .black.opacity(0.2),
        radius: CGFloat = 10,
        x: CGFloat = 0,
        y: CGFloat = 5
    ) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }
}

public extension PlatformView {
    
    @discardableResult
    func dropShadow(
        color: Color = .black,
        opacity: Float = 0.2,
        radius: CGFloat = 10,
        offset: CGSize = CGSize(width: 0, height: 5),
        cornerRadius: CGFloat? = nil
    ) -> Self {
#if os(iOS)
        layer.shadowColor = UIColor(color).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
        if let cornerRadius {
            layer.cornerRadius = cornerRadius
        }
#elseif os(macOS)
        wantsLayer = true
        layer?.shadowColor = NSColor(color).cgColor
        layer?.shadowOpacity = opacity
        layer?.shadowRadius = radius
        layer?.shadowOffset = CGSize(width: offset.width, height: -offset.height)
        layer?.masksToBounds = false
        if let cornerRadius {
            layer?.cornerRadius = cornerRadius
        }
#endif
        return self
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
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing,
        cornerRadius: CGFloat = 12,
        shimmer: Bool = true,
        breathing: Bool = true,
        scalingEffect: Bool = true
    ) -> PlatformView {
        let rootView = GradientBackgroundView(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint,
            cornerRadius: cornerRadius,
            shimmer: shimmer,
            breathing: breathing,
            scalingEffect: scalingEffect
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
