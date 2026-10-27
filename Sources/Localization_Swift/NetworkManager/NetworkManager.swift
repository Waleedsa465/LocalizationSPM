import Foundation
import Network

public extension Notification.Name {
    static let networkStatusChanged = Notification.Name("NetworkManager.networkStatusChanged")
}

public enum NetworkStatus: Sendable { case wifi, ethernet, other, disconnected }

public final class NetworkManager: @unchecked Sendable {

    public static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkManager.monitor")
    private var lastStatus: NetworkStatus?
    private var started = false

    private init() {}

    public var status: NetworkStatus { Self.status(for: monitor.currentPath) }
    public var isConnected: Bool { status != .disconnected }
    public var isExpensive: Bool { monitor.currentPath.isExpensive }

    public func start() {
        guard !started else { return }
        started = true
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let newStatus = Self.status(for: path)
            guard newStatus != lastStatus else { return }
            lastStatus = newStatus
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .networkStatusChanged, object: self)
            }
        }
        monitor.start(queue: queue)
    }

    private static func status(for path: NWPath) -> NetworkStatus {
        guard path.status == .satisfied else { return .disconnected }
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .other
    }
}
