import Foundation

open class LocalizationUtility: NSObject {
    public override init() {}
    
    @MainActor
    open class func localizeViewHierarchy(view: PlatformView) {
        for subview in view.subviews {
            localizeView(subview)
            localizeViewHierarchy(view: subview)
        }
    }
    @MainActor
    open class func resetToLocalizationKeys(view: PlatformView) {
        for subview in view.subviews {
            resetView(subview)
            resetToLocalizationKeys(view: subview)
        }
    }
}
