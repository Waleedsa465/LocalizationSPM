import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension PlatformView {
    @discardableResult
    func embedGradientBackground(
        colors: [Color],
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing,
        cornerRadius: CGFloat = 12,
        shimmer: Bool = true,
        breathing: Bool = true
    ) -> PlatformView {
        let rootView = GradientBackgroundView(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint,
            cornerRadius: cornerRadius,
            shimmer: shimmer,
            breathing: breathing
        )

        #if os(iOS)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(hostingController.view, at: 0)
        let hostedView = hostingController.view!

        #elseif os(macOS)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
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
