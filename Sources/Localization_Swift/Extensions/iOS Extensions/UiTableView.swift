#if os(iOS)
import UIKit
import Foundation

extension UITableView {
    func reloadVisibleCurrentRows() {
        guard let visibleIndexPaths = indexPathsForVisibleRows else { return }
        reloadRows(at: visibleIndexPaths, with: .automatic)
    }
}
#endif
