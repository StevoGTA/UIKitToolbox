//
//  UKTTextField.swift
//  UIKit Toolbox
//
//  Created by Stevo on 3/20/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTTextField
class UKTTextField : UITextField {

	// MARK: Properties
			var	textDidChangeProc :(_ text :String) -> Void = { _ in }

	private	var	notificationObservers = [NSObjectProtocol]()

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	override init(frame :CGRect) {
		// Do super
		super.init(frame: frame)

		// Setup notifications
		self.notificationObservers.append(
				NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self,
						using: { [unowned self] _ in self.textDidChangeProc(self.text!) }))
	}

	//------------------------------------------------------------------------------------------------------------------
	required init?(coder :NSCoder) {
		// Do super
		super.init(coder: coder)

		// Setup notifications
		self.notificationObservers.append(
				NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self,
						using: { [unowned self] _ in self.textDidChangeProc(self.text!) }))
	}

	//------------------------------------------------------------------------------------------------------------------
	deinit {
		// Cleanup
		self.notificationObservers.forEach() { NotificationCenter.default.removeObserver($0) }
	}
}
