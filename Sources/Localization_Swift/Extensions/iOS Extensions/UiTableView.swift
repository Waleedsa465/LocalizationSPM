//
//  File.swift
//  Localization_Swift
//
//  Created by Personal on 16/01/2026.
//

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
