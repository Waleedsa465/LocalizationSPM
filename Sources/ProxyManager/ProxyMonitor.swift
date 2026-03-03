// MARK: - Detect if Any Proxy Enabled For Api Calling for iOS + macOS

import Foundation
import NetworkExtension
import Localization_Swift

#if os(macOS)
class ProxyMonitor {
    
    private var proxyObservationTask: Task<Void, Never>?
    private var alert: NSAlert?
    var isEnableProxy: Bool = false
    
    func startMonitoringProxySettings() {
        proxyObservationTask = Task(priority: .high) {
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(0.2) * 1_000_000_000)
                    await checkProxySettings()
                } catch {
                    print("Failed to sleep: \(error)")
                    break
                }
            }
        }
    }

    func stopMonitoringProxySettings() {
        proxyObservationTask?.cancel()
    }

    private func checkProxySettings() async {
        if isProxyEnabled() {
            isEnableProxy = true
            await showAlertForProxyDetection()
        } else {
            isEnableProxy = false
            await closeAlertIfVisible()
        }
    }

    func isProxyEnabled() -> Bool {
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

    private func showAlertForProxyDetection() async {
        if alert?.window.isVisible == true {
            return
        }
        if alert != nil {
            self.alert = NSAlert()
        }
        Task { @MainActor in
            self.alert = NSAlert()
            self.alert?.messageText = "Third-Party Proxy Detected".localized()
            self.alert?.informativeText = """
            A third-party proxy or auto-configuration (PAC) has been detected on your system.
            This may allow interception of network traffic, including passwords, or sensitive data.

            For security:
            • Disable any debugging proxies like (Charles, Proxyman, mitmproxy, Fiddler, Burp Suite, Wireshark, ZAP Proxy, SSLsplit, HTTP Toolkit, Tcpdump, Cain and Abel, Paros Proxy, Nox App Player, Squid Proxy, Privoxy, Mitmweb, etc.)
            • Check System Settings → Network → [Your Connection] → Details… → Proxies
            """.localized()
            self.alert?.alertStyle = .critical
            self.alert?.beginSheetModal(for: appDelegate.window) { response in
                if response == .alertFirstButtonReturn {
                    print("Done button tapped")
                }
                self.alert?.window.close()
                self.alert = nil
            }
        }
    }

    private func closeAlertIfVisible() async {
        Task { @MainActor in
            self.alert?.window.close()
            self.alert = nil
        }
    }
}
#endif
#if os(iOS)
import UIKit

class ProxyMonitor {
    
    private var proxyObservationTask: Task<Void, Never>?
    private var alert: UIAlertController?
    var isEnableProxy: Bool = false
    
    func startMonitoringProxySettings() {
        proxyObservationTask = Task(priority: .high) {
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(0.2) * 1_000_000_000)
                    await checkProxySettings()
                } catch {
                    print("Failed to sleep: \(error)")
                    break
                }
            }
        }
    }

    func stopMonitoringProxySettings() {
        proxyObservationTask?.cancel()
    }

    private func checkProxySettings() async {
        if isProxyEnabled() {
            isEnableProxy = true
            await showAlertForProxyDetection()
        } else {
            isEnableProxy = false
            await closeAlertIfVisible()
        }
    }

    func isProxyEnabled() -> Bool {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else { return false }
        let isHTTPProxyEnabled = proxySettings[kCFNetworkProxiesHTTPEnable as String] as? Bool ?? false
        let isProxyAutoConfigEnabled = proxySettings[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Bool ?? false
        let isPACURLSet = proxySettings[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String != nil
        return isHTTPProxyEnabled || isProxyAutoConfigEnabled || isPACURLSet
    }

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
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,let alert {
                if let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func closeAlertIfVisible() async {
        await MainActor.run {
            alert?.dismiss(animated: true, completion: {[weak self] in
                guard let self else{return}
                alert = nil
            })
        }
    }
}
#endif




// MARK: - Usage Called this code in AppDelegate application launch
/*
 let proxyMonitor = ProxyMonitor()
 proxyMonitor.startMonitoringProxySettings()
 */
