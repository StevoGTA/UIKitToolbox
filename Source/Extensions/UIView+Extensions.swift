//
//  UIView+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/22/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIView extension
extension UIView {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func removeAllSubviews() { self.subviews.forEach() { $0.removeFromSuperview() } }

	//------------------------------------------------------------------------------------------------------------------
	func infoForButton(with selector :Selector, forControlEvent controlEvent :UIControl.Event) ->
			(button :UIButton, target :AnyHashable)? {
		// Iterate all subviews
		for view in self.subviews {
			// Check if button
			if let button = view as? UIButton {
				// Iterate all targets
				for target in button.allTargets {
					// Check
					if button.actions(forTarget: target, forControlEvent: controlEvent)?.first == "\(selector)" {
						// Found
						return (button, target)
					}
				}
			} else if let info = view.infoForButton(with: selector, forControlEvent: controlEvent) {
				// Found button
				return info
			}
		}

		return nil
	}

	//------------------------------------------------------------------------------------------------------------------
	func instancesDeep<T>() -> [T] {
		// Setup
		var	results = [T]()

		// Iterate all subviews
		for view in self.subviews {
			// Check type
			if let object = view as? T {
				// Add to resuts
				results.append(object)
			} else {
				// Iterate deeper
				results += view.instancesDeep()
			}
		}

		return results
	}
}
