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

	// MARK: Properties
	var	defaultSectionHeaderHeight :CGFloat { 28.0 }

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func height(for tableView :UITableView) -> CGFloat {
		// Setup
		let	rowHeight = (tableView.rowHeight != -1) ? tableView.rowHeight : tableView.visibleCells.first!.bounds.height
		let	numberOfSections = self.numberOfSections?(in: tableView) ?? 1

		// Calculate height
		let	height :CGFloat =
					(0..<numberOfSections).reduce(0.0,
							{ $0 + rowHeight * CGFloat(self.tableView(tableView, numberOfRowsInSection: $1)) })

		return height
	}

	//------------------------------------------------------------------------------------------------------------------
	func height(for tableView :UITableView, sectionHeaderHeight :CGFloat) -> CGFloat {
		// Setup
		let	rowHeight = (tableView.rowHeight != -1) ? tableView.rowHeight : tableView.visibleCells.first!.bounds.height
		let	numberOfSections = self.numberOfSections?(in: tableView) ?? 1

		// Calculate height
		let	height :CGFloat =
					CGFloat(numberOfSections) * sectionHeaderHeight +
							(0..<numberOfSections).reduce(0.0,
									{ $0 + rowHeight * CGFloat(self.tableView(tableView, numberOfRowsInSection: $1)) })

		return height
	}
}
