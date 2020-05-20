//
//  UKTTouchForwardingView.swift
//  UIKit Toolbox
//
//  Created by Stevo on 5/15/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTTouchForwardingView
class UKTTouchForwardingView : UIView {

	// MARK: Properties
	@IBOutlet	var	targetView :UIView?

	// MARK: NSResponder methods
	//------------------------------------------------------------------------------------------------------------------
	override func point(inside point :CGPoint, with event :UIEvent?) -> Bool {
		// Send to target
		return self.targetView?.point(inside: point, with: event) ?? false
	}

	//------------------------------------------------------------------------------------------------------------------
	override func touchesBegan(_ touches :Set<UITouch>, with event :UIEvent?) {
		// Send to target
		self.targetView?.touchesBegan(touches, with: event)
	}

	//------------------------------------------------------------------------------------------------------------------
	override func touchesMoved(_ touches :Set<UITouch>, with event :UIEvent?) {
		// Send to target
		self.targetView?.touchesMoved(touches, with: event)
	}

	//------------------------------------------------------------------------------------------------------------------
	override func touchesEnded(_ touches :Set<UITouch>, with event :UIEvent?) {
		// Send to target
		self.targetView?.touchesEnded(touches, with: event)
	}

	//------------------------------------------------------------------------------------------------------------------
	override func touchesCancelled(_ touches :Set<UITouch>, with event :UIEvent?) {
		// Send to target
		self.targetView?.touchesCancelled(touches, with: event)
	}
}
