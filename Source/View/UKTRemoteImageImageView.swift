//
//  UKTRemoteImageImageView.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/20/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTRemoteImageImageView
class UKTRemoteImageImageView : UIImageView {

	// MARK: Properties
	private	var	item :Any?
	private	var	remoteImageRetriever :UKTRemoteImageRetriever!

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func setup(with item :Any, remoteImageRetriever :UKTRemoteImageRetriever, defaultImage :UIImage? = nil) {
		// Cleanup if necessary
		cleanup()

		// Store
		self.item = item
		self.remoteImageRetriever = remoteImageRetriever

		// Setup UI
		self.image = defaultImage

		// Query image
		self.remoteImageRetriever.queryRemoteImage(for: self.item!) { [weak self] image in
			// Note that we are loaded
			self?.item = nil

			// Update UI
			self?.image = image
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	func cleanup() {
		// Check if we have a thing
		if self.item != nil {
			// Cancel any remote image query that is in-flight
			self.remoteImageRetriever.cancelQueryRemoteImage(for: self.item!)
			self.item = nil
		}
	}
}
