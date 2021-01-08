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
	private	var	remoteImageRetriever :UKTRemoteImageRetriever?
	private	var	identifier :String?

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func setup(with item :Any, remoteImageRetriever :UKTRemoteImageRetriever, defaultImage :UIImage? = nil,
			aspectFit :Bool = true) {
		// Cleanup if necessary
		cleanup()

		// Setup
		if let image = remoteImageRetriever.image(for: item, size: self.bounds.size, aspectFit: aspectFit) {
			// Have image
			self.image = image
		} else {
			// Store
			self.remoteImageRetriever = remoteImageRetriever

			// Setup UI
			self.image = defaultImage

			// Retrieve image
			self.identifier =
					self.remoteImageRetriever!.retrieveRemoteImage(for: item, size: self.bounds.size,
							aspectFit: aspectFit) { [weak self] image, error in
								// Note that we are loaded
								self?.identifier = nil

								// Update UI
								self?.image = image ?? UIImage(systemName: "exclamationmark.triangle")
							}
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	func cleanup() {
		// Check if we have a thing
		if self.identifier != nil {
			// Cancel in-flight
			self.remoteImageRetriever!.cancelRetrieveRemoteImage(for: self.identifier!)
			self.identifier = nil
		}
	}
}
