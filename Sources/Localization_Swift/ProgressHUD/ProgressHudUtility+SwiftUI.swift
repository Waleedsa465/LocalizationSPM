import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private struct ProgressHUDAnchorView {
    @Binding var isShowing: Bool
    
    @MainActor func makeView() -> PlatformView {
        let view = PlatformView()
#if os(iOS)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
#elseif os(macOS)
        view.wantsLayer = true
#endif
        return view
    }
    
    func updateView(_ view: PlatformView) {
        Task { @MainActor in
            if isShowing {
                ProgressHudUtility.shared.showHUD(on: view)
            } else {
                ProgressHudUtility.shared.hideHUD(view: view)
            }
        }
    }
}

extension ProgressHUDAnchorView: PlatformViewRepresentable {
#if os(iOS)
    func makeUIView(context: Context) -> PlatformView { makeView() }
    func updateUIView(_ uiView: PlatformView, context: Context) { updateView(uiView) }
    static func dismantleUIView(_ uiView: PlatformView, coordinator: ()) { teardown(uiView) }
#elseif os(macOS)
    func makeNSView(context: Context) -> PlatformView { makeView() }
    func updateNSView(_ nsView: PlatformView, context: Context) { updateView(nsView) }
    static func dismantleNSView(_ nsView: PlatformView, coordinator: ()) { teardown(nsView) }
#endif
    
    private static func teardown(_ view: PlatformView) {
        Task { @MainActor in
            ProgressHudUtility.shared.hideHUD(view: view)
        }
    }
}

public extension View {
    func progressHUD(isShowing: Binding<Bool>) -> some View {
        overlay(ProgressHUDAnchorView(isShowing: isShowing))
    }
}
