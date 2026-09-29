import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private struct ProgressHUDAnchorView {
    @MainActor func makeView() -> PlatformView {
        let view = PlatformView()
#if os(iOS)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
#elseif os(macOS)
        view.wantsLayer = true
#endif
        ProgressHudUtility.shared.showHUD(on: view)
        return view
    }

    @MainActor private static func teardown(_ view: PlatformView) {
        ProgressHudUtility.shared.hideHUD(view: view)
    }
}

extension ProgressHUDAnchorView: PlatformViewRepresentable {
#if os(iOS)
    func makeUIView(context: Context) -> PlatformView { makeView() }
    func updateUIView(_ uiView: PlatformView, context: Context) {}
    static func dismantleUIView(_ uiView: PlatformView, coordinator: ()) { teardown(uiView) }
#elseif os(macOS)
    func makeNSView(context: Context) -> PlatformView { makeView() }
    func updateNSView(_ nsView: PlatformView, context: Context) {}
    static func dismantleNSView(_ nsView: PlatformView, coordinator: ()) { teardown(nsView) }
#endif
}

public extension View {
    @ViewBuilder
    func progressHUD(isShowing: Binding<Bool>) -> some View {
        overlay {
            if isShowing.wrappedValue {
                ProgressHUDAnchorView()
            }
        }
    }
}
