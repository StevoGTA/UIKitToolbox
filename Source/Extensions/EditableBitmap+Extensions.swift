//
//  EditableBitmap+Extensions.swift
//  Swift Toolbox
//
//  Created by Stevo on 7/7/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import CoreGraphics
import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: EditableBitmap extension
extension EditableBitmap {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func draw(image :UIImage, in rect :CGRect? = nil) {
		// Draw
		self.context.draw(image.cgImage!, in: rect ?? CGRect(origin: CGPoint.zero, size: self.size))
	}
}
