//
//  UKTTextField.swift
//  UIKit Toolbox
//
//  Created by Stevo on 3/20/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTTextField
class UKTTextField : UITextField, UITextFieldDelegate {

	// MARK: Properties
			var	textDidChangeProc :(_ text :String) -> Void = { _ in }
			var	shouldReturnProc :(_ textField :UKTTextField) -> Bool = { _ in false }

	private	var	notificationObservers = [NSObjectProtocol]()

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	override init(frame :CGRect) {
		// Do super
		super.init(frame: frame)

		// Setup
		self.delegate = self

		// Setup notifications
		self.notificationObservers.append(
				NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self,
						using: { [unowned self] _ in self.textDidChangeProc(self.text!) }))
	}

	//------------------------------------------------------------------------------------------------------------------
	required init?(coder :NSCoder) {
		// Do super
		super.init(coder: coder)

		// Setup
		self.delegate = self

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

	// MARK: UITextFieldDelegate methods
	//------------------------------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField :UITextField) -> Bool { self.shouldReturnProc(textField as! UKTTextField) }
}
