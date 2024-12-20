//
//  UKTTreeView.swift
//  UIKit Toolbox
//
//  Created by Stevo on 5/11/21.
//  Copyright © 2021 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTTreeView
class UKTTreeView : UICollectionView, UICollectionViewDelegate {

	// MARK: Types
	typealias ConfigureTreeItemCellProc =
				(_ treeItem :TreeItem, _ collectionViewListCell :UICollectionViewListCell, _ itemID :String) -> Void
	typealias SelectionDidChangeProc = () -> Void

	// MARK: Properties
			var	hasChildTreeItemsProc :TreeViewBacking.HasChildTreeItemsProc? {
						get { self.treeViewBacking.hasChildTreeItemsProc }
						set { self.treeViewBacking.hasChildTreeItemsProc = newValue }
					}
			var	childTreeItemsProc :TreeViewBacking.ChildTreeItemsProc? {
						get { self.treeViewBacking.childTreeItemsProc }
						set { self.treeViewBacking.childTreeItemsProc = newValue }
					}
			var	loadChildTreeItemsProc :TreeViewBacking.LoadChildTreeItemsProc? {
						get { self.treeViewBacking.loadChildTreeItemsProc }
						set { self.treeViewBacking.loadChildTreeItemsProc = newValue }
					}
			var	compareTreeItemsProc :TreeViewBacking.CompareTreeItemsProc {
						get { self.treeViewBacking.compareTreeItemsProc }
						set { self.treeViewBacking.compareTreeItemsProc = newValue }
					}
			var	configureTreeItemCellProc :ConfigureTreeItemCellProc?
			var	shouldSelectTreeItemProc :(_ treeItem :TreeItem) -> Bool = { _ in true }
			var	selectionDidChangeProc :SelectionDidChangeProc?

	private	let	treeViewBacking = TreeViewBacking()

	private	var	expandedItemIDs = Set<String>()
	private	var	dataSourceInstance :UICollectionViewDiffableDataSource<Int, String>!
	private	var	snapshotInstance :NSDiffableDataSourceSnapshot<Int, String>!

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	required init?(coder :NSCoder) {
		// Do super
		super.init(coder: coder)

		// Setup
		let	layoutListConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
		self.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: layoutListConfiguration)

		let cellRegistration =
					UICollectionView.CellRegistration<UICollectionViewListCell, String>()
							{ [unowned self] in // (cell, indexPath, itemID) in
								// Setup
								let	itemID = $2

								$0.accessories = []
								self.configureTreeItemCellProc?(self.treeViewBacking.treeItem(for: itemID), $0, itemID)
								$0.indentationLevel = self.treeViewBacking.indentationLevel(for: itemID) - 1

								// Check if should show accessory
								let	actionHandler :UICellAccessory.ActionHandler?
								if self.treeViewBacking.hasChildren(of: itemID) {
									// Setup accessory
									if self.expandedItemIDs.contains(itemID) {
										// Expanded
										actionHandler = { [unowned self] in self.collapse(itemID: itemID) }
									} else {
										// Not expanded
										actionHandler = { [unowned self] in self.expand(itemID: itemID) }
									}
								} else {
									// Not expandable
									actionHandler = nil
								}

								$0.accessories =
										$0.accessories +
												[UICellAccessory.outlineDisclosure(
														options:
																UICellAccessory.OutlineDisclosureOptions(
																		style: .cell,
																		isHidden: actionHandler == nil,
																		reservedLayoutWidth: .standard),
														actionHandler: actionHandler)]
							}
		self.dataSourceInstance =
				UICollectionViewDiffableDataSource<Int, String>(collectionView: self)
						{ $0.dequeueConfiguredReusableCell(using: cellRegistration, for: $1, item: $2) }
		self.dataSourceInstance.sectionSnapshotHandlers.willExpandItem = { [unowned self] in
			// Add as expanded
			self.expandedItemIDs.insert($0)
		}
		self.dataSourceInstance.sectionSnapshotHandlers.willCollapseItem = { [unowned self] in
			// Remove as expanded
			self.expandedItemIDs.remove($0)
		}
		self.dataSource = self.dataSourceInstance

		self.delegate = self
	}

	// MARK: UICollectionViewDelegate methods
	//------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView :UICollectionView, shouldSelectItemAt indexPath :IndexPath) -> Bool {
		// Call proc
		return self.shouldSelectTreeItemProc(
				self.treeViewBacking.treeItem(for: self.dataSourceInstance.itemIdentifier(for: indexPath)!))
	}

	//------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView :UICollectionView, didSelectItemAt indexPath :IndexPath) {
		// Call proc
		self.selectionDidChangeProc?()
	}

	//------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView : UICollectionView, didDeselectItemAt indexPath :IndexPath) {
		// Call proc
		self.selectionDidChangeProc?()
	}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func set(rootTreeItem :TreeItem) {
		// Store
		self.treeViewBacking.set(rootTreeItem: rootTreeItem)

		// Update UI
		self.reloadSnapshot()
	}

	//------------------------------------------------------------------------------------------------------------------
	func set(topLevelTreeItems :[TreeItem]) {
		// Store
		self.treeViewBacking.set(topLevelTreeItems: topLevelTreeItems)

		// Update UI
		self.reloadSnapshot()
	}

	//------------------------------------------------------------------------------------------------------------------
	func noteNeedsReload(itemID :String, reloadSnapshot :Bool = true) {
		// Update TreeViewBacking
		self.treeViewBacking.noteNeedsReload(itemID: itemID)

		// Update UI
		if reloadSnapshot {
			// Reload snapshot
			self.reloadSnapshot()
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	func expand(itemID :String) {
		// Expand
		self.expandedItemIDs.insert(itemID)

		// Update UI
		var	snapshot = self.dataSourceInstance.snapshot()
		snapshot.reloadItems([itemID])
		self.dataSourceInstance.apply(snapshot)

		self.reloadSnapshot(animated: true)

		// Call proc
		self.selectionDidChangeProc?()
	}

	//------------------------------------------------------------------------------------------------------------------
	func collapse(itemID :String) {
		// Collapse
		self.expandedItemIDs.remove(itemID)

		// Update UI
		var	snapshot = self.dataSourceInstance.snapshot()
		snapshot.reloadItems([itemID])
		self.dataSourceInstance.apply(snapshot)

		self.reloadSnapshot(animated: true)

		// Call proc
		self.selectionDidChangeProc?()
	}

	//------------------------------------------------------------------------------------------------------------------
	func isExpanded(itemID :String) -> Bool { self.expandedItemIDs.contains(itemID) }

	//------------------------------------------------------------------------------------------------------------------
	func treeItem(at indexPath :IndexPath) -> TreeItem {
		// Return Item
		return self.treeViewBacking.treeItem(for: self.dataSourceInstance.itemIdentifier(for: indexPath)!)
	}

	// MARK: Private methods
	//------------------------------------------------------------------------------------------------------------------
	private func reloadSnapshot(animated :Bool = false) {
		// Setup
		self.snapshotInstance = NSDiffableDataSourceSnapshot<Int, String>()
		self.snapshotInstance.appendSections([0])
		self.snapshotInstance.appendItems(self.treeViewBacking.itemIDs(with: self.expandedItemIDs))

		// Apply
		self.dataSourceInstance.apply(self.snapshotInstance, animatingDifferences: animated)
	}
}

/*
iOS/tvOS:
	UICollectionView
	Swift

macOS:
	NSOutlineView
	Swift

	C++ compatible - Obj-C++???a
	-or-
	C++ with other C++ modules like CSearchEngine that can be cross-platform for C++ objects

	So, yes, C++ implementation based on Swift implementation
	? Possible to make a single Swift implementation that con go for both iOS/tvOS & macOS

	macOS (NSOutlineView):
		maintains hierarchy internally
		interacts through "item"
		backing maintains "item" object with pointer to model object

	iOS (UICollectionView)
		maintains section/row
		interacts through section/row
		can take advantage of diffabble data source
		must maintain independent tree of backing items
			backing item must point to model object
			backing item must maintain "indentation" level

	iOS UICollectionView
		-> UIDiffableDataSource
			-> TreeViewBacking
*/
