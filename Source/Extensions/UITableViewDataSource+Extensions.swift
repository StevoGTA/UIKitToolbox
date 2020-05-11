//
//  UITableView+Extensions.swift
//  Virtual Sheet Music
//
//  Created by Stevo on 5/11/20.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UITableViewDataSource extension
extension UITableViewDataSource {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func height(for tableView :UITableView, sectionHeaderHeight :CGFloat? = nil, sectionFooterHeight :CGFloat? = nil) ->
			CGFloat {
		// Setup
		let	rowHeight = (tableView.rowHeight != -1) ? tableView.rowHeight : tableView.visibleCells.first!.bounds.height
		let	sectionHeaderHeightUse = sectionHeaderHeight ?? 28.0
		let	sectionFooterHeightUse = sectionFooterHeight ?? 0.0
		let	numberOfSections = self.numberOfSections?(in: tableView) ?? 1

		var	height :CGFloat = 0.0

		// Check number of sections
		if numberOfSections == 1 {
			// 1 section
			height = rowHeight * CGFloat(self.tableView(tableView, numberOfRowsInSection: 0))
		} else {
			// Iterate sections
			for section in 0..<numberOfSections {
				// Update height
				height +=
						sectionHeaderHeightUse + sectionFooterHeightUse +
								rowHeight * CGFloat(self.tableView(tableView, numberOfRowsInSection: section))
			}
		}

		return height
	}
}
