//
//  UKTTextField.swift
//  Swift Toolbox
//
//  Created by Stevo on 3/20/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTTextField
class UKTTextField : UITextField {

	// MARK: Properties
			var	textDidChangeProc :() -> Void = {}

	private	var	notificationObservers = [NSObjectProtocol]()

	// MARK: Lifecycle methods
	//----------------------------------------------------------------------------------------------------------------------
	override init(frame :CGRect) {
		// Do super
		super.init(frame: frame)

		// Setup notifications
		NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self)
				{ [unowned self] _ in self.textDidChangeProc() }
	}

	//----------------------------------------------------------------------------------------------------------------------
	required init?(coder :NSCoder) {
		// Do super
		super.init(coder: coder)

		// Setup notifications
		NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self)
				{ [unowned self] _ in self.textDidChangeProc() }
	}

	//------------------------------------------------------------------------------------------------------------------
	deinit {
		// Cleanup
		self.notificationObservers.forEach() { NotificationCenter.default.removeObserver($0) }
	}
}
