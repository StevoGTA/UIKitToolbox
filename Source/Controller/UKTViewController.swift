//
//  UKTViewController.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/13/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTViewController
class UKTViewController : UIViewController {

	// MARK: Properties
	private	var	notificationObservers = [NSObjectProtocol]()

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	deinit {
		// Cleanup
		self.notificationObservers.forEach() { NotificationCenter.default.removeObserver($0) }
	}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func addNotificationObserver(forName name :NSNotification.Name, object :Any? = nil, queue :OperationQueue? = nil,
			proc :@escaping (Notification) -> Void) {
		// Add
		self.notificationObservers.append(
				NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: proc))
	}
}
