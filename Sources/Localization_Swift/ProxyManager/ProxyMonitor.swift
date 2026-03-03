// MARK: - Detect if Any Proxy Enabled For Api Calling for iOS + macOS

import Foundation
import NetworkExtension

#if os(macOS)

import Cocoa

@MainActor
open class ProxyMonitor: NSObject {

    public var alert: NSAlert?
    public var isEnableProxy: Bool = false
    private var proxyObservationTask: Task<Void, Never>?

    public override init() {
        super.init()
    }

    // Start monitoring proxy settings (instance method)
    open func startMonitoringProxySettings() {
        proxyObservationTask = Task(priority: .high) {
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(2.0) * 1_000_000_000)
                    await self.checkProxySettings() // Call instance method
                } catch {
                    print("Failed to sleep: \(error)")
                    break
                }
            }
        }
    }
    
    // Stop monitoring proxy settings (instance method)
    open func stopMonitoringProxySettings() {
        proxyObservationTask?.cancel()
    }
    
    // Check the proxy settings (instance method)
    private func checkProxySettings() async {
        if isProxyEnabled() {
            isEnableProxy = true
            await showAlertForProxyDetection()
        } else {
            isEnableProxy = false
            await closeAlertIfVisible()
        }
    }

    // Check if any proxy is enabled
    public func isProxyEnabled() -> Bool {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return false
        }
        return (proxySettings[kCFNetworkProxiesHTTPEnable as String] as? Bool ?? false) ||
               (proxySettings[kCFNetworkProxiesHTTPSEnable as String] as? Bool ?? false) ||
               (proxySettings[kCFNetworkProxiesSOCKSEnable as String] as? Bool ?? false) ||
               (proxySettings[kCFNetworkProxiesFTPEnable as String] as? Bool ?? false) ||
               (proxySettings[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Bool ?? false) ||
               (proxySettings[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String != nil)
    }

    // Show alert if proxy is detected
    private func showAlertForProxyDetection() async {
        // Ensure that we update the UI on the main thread
        if alert?.window.isVisible == true {
            return
        }
        if alert == nil {
            self.alert = NSAlert()
        }

        alert?.messageText = "Third-Party Proxy Detected"
        alert?.informativeText = """
        A third-party proxy or auto-configuration (PAC) has been detected on your system.
        This may allow interception of network traffic, including passwords, or sensitive data.

        For security:
        • Disable any debugging proxies like (Charles, Proxyman, mitmproxy, Fiddler, Burp Suite, Wireshark, ZAP Proxy, SSLsplit, HTTP Toolkit, Tcpdump, Cain and Abel, Paros Proxy, Nox App Player, Squid Proxy, Privoxy, Mitmweb, etc.)
        • Check System Settings → Network → [Your Connection] → Details… → Proxies
        """
        alert?.alertStyle = .critical

        // Show the alert on the main thread (UI updates should always be done on the main thread)
        await MainActor.run {
            self.alert?.beginSheetModal(for: NSApplication.shared.windows.first ?? NSWindow()) { response in
                if response == .alertFirstButtonReturn {
                    print("Done button tapped")
                }
                self.alert?.window.close()
                self.alert = nil
            }
        }
    }
    
    // Close the alert if it's visible
    private func closeAlertIfVisible() async {
        await MainActor.run {
            self.alert?.window.close()
            self.alert = nil
        }
    }
}

#endif
#if os(iOS)

import UIKit

@MainActor
open class ProxyMonitor: NSObject {

    public override init() { }
    
    private var alert: UIAlertController?
    public var isEnableProxy: Bool = false
    private var proxyObservationTask: Task<Void, Never>?

    // Start monitoring proxy settings (instance method)
    open func startMonitoringProxySettings() {
        proxyObservationTask = Task(priority: .high) {
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(2.0) * 1_000_000_000)
                    await self.checkProxySettings() // Access instance method
                } catch {
                    print("Failed to sleep: \(error)")
                    break
                }
            }
        }
    }

    // Stop monitoring proxy settings (instance method)
    open func stopMonitoringProxySettings() {
        proxyObservationTask?.cancel()
    }

    // Check proxy settings (instance method)
    private func checkProxySettings() async {
        if isProxyEnabled() {
            isEnableProxy = true
            await showAlertForProxyDetection()
        } else {
            isEnableProxy = false
            await closeAlertIfVisible()
        }
    }

    // Check if any proxy is enabled
    func isProxyEnabled() -> Bool {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else { return false }
        let isHTTPProxyEnabled = proxySettings[kCFNetworkProxiesHTTPEnable as String] as? Bool ?? false
        let isProxyAutoConfigEnabled = proxySettings[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Bool ?? false
        let isPACURLSet = proxySettings[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String != nil
        return isHTTPProxyEnabled || isProxyAutoConfigEnabled || isPACURLSet
    }

    // Show alert if proxy is detected
    private func showAlertForProxyDetection() async {
        if alert?.view.superview != nil {
            return
        }
        
        if alert == nil {
            alert = UIAlertController(title: "Third-Party Proxy Detected", message: """
                A third-party proxy or auto-configuration (PAC) has been detected on your system.
                This may allow interception of network traffic, including passwords or sensitive data.

                For security:
                • Disable any debugging proxies like Charles, Proxyman, mitmproxy, Fiddler, Burp Suite, etc.
                • Check System Settings → Network → [Your Connection] → Details... → Proxies
                """, preferredStyle: .alert)
            
            alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                print("Alert acknowledged.")
            }))
        }
        
        // Present the alert on the main thread
        await MainActor.run {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let alert {
                if let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // Close the alert if visible
    private func closeAlertIfVisible() async {
        await MainActor.run {
            self.alert?.dismiss(animated: true, completion: { [weak self] in
                self?.alert = nil
            })
        }
    }
}

#endif
