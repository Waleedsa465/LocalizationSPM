#if os(iOS)
import UIKit
import Foundation

extension UITableView {
    public func reloadVisibleCurrentRows() {
        guard let visibleIndexPaths = indexPathsForVisibleRows else { return }
        reloadRows(at: visibleIndexPaths, with: .automatic)
    }
}
#endif
