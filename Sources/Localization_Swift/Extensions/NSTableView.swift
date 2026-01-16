//
//  NSTableView.swift
//  Genmoji
//
//  Created by Macbook Pro on 19/05/2025.
//
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
