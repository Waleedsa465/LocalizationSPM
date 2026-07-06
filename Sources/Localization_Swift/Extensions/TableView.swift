#if os(iOS)
import UIKit
typealias PlatformTableView = UITableView
#elseif os(macOS)
import Cocoa
typealias PlatformTableView = NSTableView
#endif

public extension PlatformTableView {
    
    func reloadVisibleCurrentRows() {
#if os(iOS)
        guard let visibleIndexPaths = indexPathsForVisibleRows else { return }
        reloadRows(at: visibleIndexPaths, with: .automatic)
#elseif os(macOS)
        let visibleRect = visibleRect
        let visibleRows = rows(in: visibleRect)
        let visibleIndexSet = IndexSet(integersIn: visibleRows.lowerBound..<visibleRows.upperBound)
        reloadData(forRowIndexes: visibleIndexSet, columnIndexes: IndexSet(integersIn: 0..<numberOfColumns))
#endif
    }
    
}
