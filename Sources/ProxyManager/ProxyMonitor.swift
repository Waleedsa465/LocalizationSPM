import Foundation

/// Base class / interface for proxy monitoring
/// Use this type everywhere in your app
open class ProxyMonitor: NSObject {
    
    public override init() {
        super.init()
    }
    
    open var isEnableProxy: Bool = false
    
    @MainActor
    open class func startMonitoringProxySettings() {
        // To be overridden in platform-specific extensions
        #if DEBUG
        print("ProxyMonitor.startMonitoringProxySettings() not implemented for this platform")
        #endif
    }
    
    @MainActor
    open class func stopMonitoringProxySettings() {
        // To be overridden
    }
    
    /// You can call this from anywhere to check current state
    public func checkNow() async {
        let enabled = isProxyEnabled()
        await MainActor.run {
            self.isEnableProxy = enabled
        }
    }
    
    /// Core proxy detection logic (shared between iOS & macOS)
    func isProxyEnabled() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return false
        }
        
        let httpEnabled   = settings[kCFNetworkProxiesHTTPEnable          as String] as? Bool ?? false
        let httpsEnabled  = settings[kCFNetworkProxiesHTTPSEnable         as String] as? Bool ?? false
        let socksEnabled  = settings[kCFNetworkProxiesSOCKSEnable         as String] as? Bool ?? false
        let ftpEnabled    = settings[kCFNetworkProxiesFTPEnable           as String] as? Bool ?? false
        let pacEnabled    = settings[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Bool ?? false
        let pacURLPresent = settings[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String != nil
        
        return httpEnabled || httpsEnabled || socksEnabled || ftpEnabled || pacEnabled || pacURLPresent
    }
}
#if os(macOS)

import AppKit
// import Localization_Swift   // ← uncomment if you really use it

extension ProxyMonitor {
    
    private static var proxyObservationTask: Task<Void, Never>?
    private static var currentAlert: NSAlert?
    
    @MainActor
    override open class func startMonitoringProxySettings() {
        stopMonitoringProxySettings()   // prevent duplicates
        
        proxyObservationTask = Task(priority: .high) { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
                    await checkProxySettings()
                } catch {
                    // usually cancellation
                    break
                }
            }
        }
    }
    
    @MainActor
    override open class func stopMonitoringProxySettings() {
        proxyObservationTask?.cancel()
        proxyObservationTask = nil
        Task { @MainActor in
            currentAlert?.window.close()
            currentAlert = nil
        }
    }
    
    private class func checkProxySettings() async {
        let monitor = ProxyMonitor() // we use instance method
        let enabled = monitor.isProxyEnabled()
        
        await MainActor.run {
            monitor.isEnableProxy = enabled
            
            if enabled {
                showProxyWarningIfNeeded()
            } else {
                closeAlertIfVisible()
            }
        }
    }
    
    @MainActor
    private class func showProxyWarningIfNeeded() {
        guard currentAlert?.window.isVisible != true else { return }
        
        let alert = NSAlert()
        alert.messageText = "Third-Party Proxy Detected".localized()
        alert.informativeText = """
        A third-party proxy or auto-configuration (PAC) has been detected.
        This may allow interception of network traffic, including passwords or sensitive data.
        
        For security:
        • Disable debugging proxies (Charles, Proxyman, mitmproxy, Burp Suite, etc.)
        • Check System Settings → Network → [Your Connection] → Details… → Proxies
        """.localized()
        
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window) { _ in
                currentAlert = nil
            }
            currentAlert = alert
        }
    }
    
    @MainActor
    private class func closeAlertIfVisible() {
        currentAlert?.window.close()
        currentAlert = nil
    }
}

#endif
#if os(iOS)

import UIKit

extension ProxyMonitor {
    
    private static var proxyObservationTask: Task<Void, Never>?
    private static weak var currentAlert: UIAlertController?
    
    @MainActor
    override open class func startMonitoringProxySettings() {
        stopMonitoringProxySettings()
        
        proxyObservationTask = Task(priority: .high) { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 200_000_000)
                    await checkProxySettings()
                } catch {
                    break
                }
            }
        }
    }
    
    @MainActor
    override open class func stopMonitoringProxySettings() {
        proxyObservationTask?.cancel()
        proxyObservationTask = nil
        Task { @MainActor in
            currentAlert?.dismiss(animated: true)
            currentAlert = nil
        }
    }
    
    private class func checkProxySettings() async {
        let monitor = ProxyMonitor()
        let enabled = monitor.isProxyEnabled()
        
        await MainActor.run {
            monitor.isEnableProxy = enabled
            
            if enabled {
                showProxyWarningIfNeeded()
            } else {
                currentAlert?.dismiss(animated: true)
                currentAlert = nil
            }
        }
    }
    
    @MainActor
    private class func showProxyWarningIfNeeded() {
        guard currentAlert == nil else { return }
        
        let alert = UIAlertController(
            title: "Third-Party Proxy Detected",
            message: """
            A third-party proxy or auto-configuration (PAC) has been detected.
            This may allow interception of network traffic, including passwords or sensitive data.
            
            For security:
            • Disable debugging proxies (Charles, Proxyman, mitmproxy, Burp Suite, etc.)
            • Check Settings → Wi-Fi → [Your network] → HTTP Proxy
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Try to find a good place to present from
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let rootVC = windowScene.windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            
            var targetVC = rootVC
            while let presented = targetVC.presentedViewController {
                targetVC = presented
            }
            
            targetVC.present(alert, animated: true)
            currentAlert = alert
        }
    }
}

#endif
