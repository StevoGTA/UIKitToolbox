//
//  UKTRemoteImageImageView.swift
//  Media Player - Apple
//
//  Created by Stevo on 4/20/20.
//  Copyright © 2020 Sunset Magicwerks, LLC. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTRemoteImageImageView
class UKTRemoteImageImageView : UIImageView {

	// MARK: Properties
	private	var	t :Any?
	private	var	remoteImageRetriever :RemoteImageRetriever!

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func setup(with t :Any, remoteImageRetriever :RemoteImageRetriever) {
		// Cleanup if necessary
		cleanup()

		// Store
		self.t = t
		self.remoteImageRetriever = remoteImageRetriever

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
			// Cancel any remote image query in flight
			self.remoteImageRetriever.cancelQueryRemoteImage(for: self.t!)
			self.t = nil
		}
	}
}
