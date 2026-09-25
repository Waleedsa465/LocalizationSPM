import Foundation

@MainActor
public final class ProgressHudUtility: NSObject {

    public static let shared = ProgressHudUtility()

    private override init() {
        super.init()
    }

    public func showHUD(on view: PlatformView) {
        Task { @MainActor in
            MBProgressHUD.showHUDAdded(to: view, animated: true)
        }
    }

    public func hideHUD(view: PlatformView) {
        Task { @MainActor in
            MBProgressHUD.hideAllHUDs(for: view, animated: true)
            for mbView in view.subviews{
                if let mbView = mbView as? MBProgressHUD{
                    mbView.removeFromSuperview()
                }
            }
        }
    }
}
