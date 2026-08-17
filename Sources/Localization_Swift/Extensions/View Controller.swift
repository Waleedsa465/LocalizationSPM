import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformViewController = UIViewController
public typealias PlatformView = UIView
#elseif canImport(AppKit)
import AppKit
public typealias PlatformViewController = NSViewController
public typealias PlatformView = NSView
#endif

#if canImport(UIKit)
public extension PlatformViewController {
    func addChildViewControllerWithAnimation(_ controller: PlatformViewController, to containerView: PlatformView) {
        addChild(controller)
        controller.view.layer.masksToBounds = true
        var initialFrame = containerView.bounds
        initialFrame.origin.x = containerView.bounds.width
        controller.view.frame = initialFrame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(controller.view)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            controller.view.frame = containerView.bounds
        }, completion: nil)
    }

    func removeChildFromNavigation() {
        let finalFrame = view.frame.offsetBy(dx: view.bounds.width, dy: 0)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.frame = finalFrame
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
}

#elseif canImport(AppKit)
public extension PlatformViewController {
    func addChildViewControllerWithAnimation(_ controller: PlatformViewController, to containerView: PlatformView) {
        addChild(controller)
        var initialFrame = containerView.bounds
        initialFrame.origin.x = containerView.bounds.width
        controller.view.frame = initialFrame
        controller.view.autoresizingMask = [.width, .height]
        containerView.addSubview(controller.view)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            controller.view.animator().frame = containerView.bounds
        }
    }

    func addChildViewControllerWithOutAnimation(_ controller: PlatformViewController, to containerView: PlatformView) {
        addChild(controller)
        controller.view.wantsLayer = true
        var initialFrame = containerView.bounds
        initialFrame.origin.x = containerView.bounds.width
        controller.view.frame = initialFrame
        controller.view.autoresizingMask = [.width, .height]
        containerView.addSubview(controller.view)
        controller.view.frame = containerView.bounds
    }

    func removeChildFromNavigation() {
        let finalFrame = view.frame.offsetBy(dx: view.bounds.width, dy: 0)
        NSAnimationContext.runAnimationGroup({ [weak self] context in
            guard let self else { return }
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            view.animator().frame = finalFrame
        }, completionHandler: { [weak self] in
            guard let self else { return }
            view.removeFromSuperview()
            removeFromParent()
        })
    }
}
#endif
