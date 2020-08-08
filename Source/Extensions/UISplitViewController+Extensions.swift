//
//  UISplitViewController+Extensions.swift
//  Virtual Sheet Music
//
//  Created by Stevo on 8/7/20.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UISplitViewController extension
extension UISplitViewController {

	// MARK: Properties
	var	primaryNavigationController :UINavigationController? { self.viewControllers[0] as? UINavigationController }
	var	topPrimaryViewController :UIViewController? { self.primaryNavigationController?.viewControllers.last }
	var	secondaryViewController :UIViewController? { self.viewControllers[1] }

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func setPrimary(rootViewController viewController :UIViewController) {
		// Set primary
		self.primaryNavigationController?.set(rootViewController: viewController)
	}
}
