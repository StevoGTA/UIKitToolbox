//
//  UIViewController+Extensions.swift
//  Swift Toolbox
//
//  Created by Stevo on 3/23/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIViewController extension
extension UIViewController {

	// MARK: Properties
	var	topViewController :UIViewController {
				// Follow the tree up the stack to the top
				var	topViewController = self
				while true {
					// Check for another top view controller
					if let presentedViewController = topViewController.presentedViewController {
						// Have presented view controller
						topViewController = presentedViewController
					} else if let navigationController = topViewController as? UINavigationController {
						// Are navigation controller
						topViewController = navigationController.visibleViewController!
					} else if let tabBarController = topViewController as? UITabBarController {
						// Are tab bar controller
						topViewController = tabBarController.selectedViewController!
					} else {
						// Are the top view controller
						return topViewController
					}
				}
			}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func presentAnimated(_ viewController :UIViewController) { present(viewController, animated: true) }
}
