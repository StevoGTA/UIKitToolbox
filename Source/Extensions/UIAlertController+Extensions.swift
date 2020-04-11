//
//  UIAlertController+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 3/20/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIAlertController extension
extension UIAlertController {

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	convenience init(title :String, message :String, preferredStyle :UIAlertController.Style = .alert,
			actionButtonTitle :String, actionProc :@escaping () -> Void = {}) {
		// Do super
		self.init(title: title, message: message, preferredStyle: preferredStyle)

		// Add action
		addAction(UIAlertAction(title: actionButtonTitle, style: .default) { _ in actionProc() })
	}

	//------------------------------------------------------------------------------------------------------------------
	convenience init(title :String, message :String, preferredStyle :UIAlertController.Style = .alert,
			actionButtonTitle :String, cancelButtonTitle :String, actionProc :@escaping () -> Void,
			cancelProc :@escaping () -> Void = {}) {
		// Do super
		self.init(title: title, message: message, preferredStyle: preferredStyle)

		// Add actions
		addAction(UIAlertAction(title: actionButtonTitle, style: .default) { _ in actionProc() })
		addAction(UIAlertAction(title: cancelButtonTitle, style: .default) { _ in cancelProc() })
	}
}
