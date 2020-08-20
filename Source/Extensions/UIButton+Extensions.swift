//
//  UIButton+Extensions.swift
//  Create Latest VSM Catalog DB
//
//  Created by Stevo on 8/19/20.
//
import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIButton extensions
extension UIButton {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func setTitleWithoutAnimation(_ title :String, for state :UIControl.State) {
		// Set title
		self.setTitle(title, for: state)

		// Layout without animation
		UIView.performWithoutAnimation() {
			// Layout
			self.layoutIfNeeded()
		}
	}
}
