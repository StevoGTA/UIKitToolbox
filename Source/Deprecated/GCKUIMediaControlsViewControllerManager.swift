//
//  GCKUIMediaControlsViewControllerManager.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/23/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import GoogleCast
import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: GCKUIMediaControlsViewControllerManager
class GCKUIMediaControlsViewControllerManager : NSObject {

	// MARK: Types
	typealias DismissProc = () -> Void

	// MARK: Properties
	static			let	shared = GCKUIMediaControlsViewControllerManager()

					var	expandedMediaControlsViewController =
								GCKCastContext.sharedInstance().defaultExpandedMediaControlsViewController
					var	expandedMediaControlsStopPlaybackWhenDismissed = true

					var	expandedMediaControlsDismissProc :DismissProc?

			private	let	expandedMediaControlsPlayPauseButton :UIButton?
			private	let	expandedMediaControlsSlider :UISlider?

			private	var	expandedMediaControlsButtonTypes = [GCKUIMediaButtonType]()

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	override init() {
		// Setup
		self.expandedMediaControlsPlayPauseButton =
				self.expandedMediaControlsViewController
						.infoForButton(with: #selector(handlePlayPauseToggleButton(_:)),
								forControlEvent: .touchUpInside)?
						.button
		self.expandedMediaControlsSlider = self.expandedMediaControlsViewController.instancesDeep().first

		// Do super
		super.init()

		// Finish setup
		for index in 0..<self.expandedMediaControlsViewController.buttonCount() {
			// Add default button type
			self.expandedMediaControlsButtonTypes.append(self.expandedMediaControlsViewController.buttonType(at: index))
		}

		if let info = self.expandedMediaControlsViewController.infoForButton(with: #selector(downArrowTapped(_:)),
				forControlEvent: .touchUpInside) {
			// Update
			info.button.removeTarget(info.target, action: #selector(downArrowTapped(_:)), for: .touchUpInside)
			info.button.addTarget(self, action: #selector(expandedMediaControlsViewControllerDownArrowTapped),
					for: .touchUpInside)
		}
	}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func makePlayPauseAndSeekControls(available :Bool) {
		// Check available
		if available {
			// Reset button types
			for index in 0..<self.expandedMediaControlsViewController.buttonCount() {
				// Add default button type
				self.expandedMediaControlsViewController.setButtonType(
						self.expandedMediaControlsButtonTypes[Int(index)], at: index)
			}

			// Show play/pause button
			self.expandedMediaControlsPlayPauseButton?.isHidden = false

			// Enable slider
			self.expandedMediaControlsSlider?.isUserInteractionEnabled = true
		} else {
			// Remove buttons
			for index in 0..<self.expandedMediaControlsViewController.buttonCount() {
				// Check button type
				switch self.expandedMediaControlsViewController.buttonType(at: index) {
					case .playPauseToggle, .skipNext, .skipPrevious, .rewind30Seconds, .forward30Seconds, .stop:
						// Remove these buttons
						self.expandedMediaControlsViewController.setButtonType(.none, at: index)

					default:
						// These can stay
						break
				}
			}

			// Hide play/pause button
			self.expandedMediaControlsPlayPauseButton?.isHidden = true

			// Disable slider
			self.expandedMediaControlsSlider?.isUserInteractionEnabled = false
		}
	}

	// MARK: Private methods
	//------------------------------------------------------------------------------------------------------------------
	@objc private func expandedMediaControlsViewControllerDownArrowTapped(_ sender :Any) {
		// Check if stopping playback
		if self.expandedMediaControlsStopPlaybackWhenDismissed {
			// Stop playback
			GoogleCastManager.shared.stop()
		}

		// Dismiss
		if self.expandedMediaControlsDismissProc != nil {
			// Call proc
			self.expandedMediaControlsDismissProc!()
		} else {
			// Dismiss animated
			self.expandedMediaControlsViewController.dismissAnimated()
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	@objc private func downArrowTapped(_ :UIButton) {}	// Placeholder

	//------------------------------------------------------------------------------------------------------------------
	@objc private func handlePlayPauseToggleButton(_ :UIButton) {}	// Placeholder
}
