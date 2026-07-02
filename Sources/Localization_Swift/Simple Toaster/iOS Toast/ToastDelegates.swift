#if os(iOS)

import Foundation
import UIKit

public protocol ToastView : UIView { func createView(for toast: Toast) }

public protocol ToastQueueDelegate: AnyObject {
    func willShowAnyToast(_ toast: Toast, queuedToasts: [Toast]) -> Void
    func didShowAnyToast(_ toast: Toast, queuedToasts: [Toast]) -> Void
}

public protocol ToastDelegate: AnyObject {
    func willShowToast(_ toast: Toast)
    func didShowToast(_ toast: Toast)
    func willCloseToast(_ toast: Toast)
    func didCloseToast(_ toast: Toast)
}

extension ToastQueueDelegate {
    public func willShowAnyToast(toast: Toast, queuedToasts: [Toast]) {}
    public func didShowAnyToast(toast: Toast, queuedToasts: [Toast]) {}
}

extension ToastDelegate {
    func willShowToast(_ toast: Toast) {}
    func didShowToast(_ toast: Toast) {}
    func willCloseToast(_ toast: Toast) {}
    func didCloseToast(_ toast: Toast) {}
}

#endif
