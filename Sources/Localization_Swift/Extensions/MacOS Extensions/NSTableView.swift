#if os(macOS)
import Cocoa

extension NSTableView {
    func reloadVisibleCurrentRows() {
        let visibleRect = visibleRect
        let visibleRows = rows(in: visibleRect)
        let visibleIndexSet = IndexSet(integersIn: visibleRows.lowerBound..<visibleRows.upperBound)
        reloadData(forRowIndexes: visibleIndexSet, columnIndexes: IndexSet(integersIn: 0..<numberOfColumns))
    }
}
#endif
