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
	private	var	t :Any?
	private	var	remoteImageRetriever :UKTRemoteImageRetriever!

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func setup(with t :Any, remoteImageRetriever :UKTRemoteImageRetriever, defaultImage :UIImage? = nil) {
		// Cleanup if necessary
		cleanup()

		// Store
		self.t = t
		self.remoteImageRetriever = remoteImageRetriever

		// Setup UI
		self.image = defaultImage

		// Query image
		self.remoteImageRetriever.queryRemoteImage(for: self.t!) { [weak self] image in
			// Update UI
			self?.image = image
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	func cleanup() {
		// Check if we have a thing
		if self.t != nil {
			// Cancel any remote image query that is in-flight
			self.remoteImageRetriever.cancelQueryRemoteImage(for: self.t!)
			self.t = nil
		}
	}
}
