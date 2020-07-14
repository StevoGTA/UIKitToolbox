//
//  UIImage+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/9/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIImage extensions
extension UIImage {

	// MARK: Class methods
	//------------------------------------------------------------------------------------------------------------------
	static func from(_ data :Data?) -> UIImage? { (data != nil) ? UIImage(data: data!) : nil }

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func draw(centeredAt point :CGPoint) {
		// Setup
		let	size = self.size;

		// Draw
		draw(at: point.offsetBy(dx: -size.width * 0.5, dy: -size.height * 0.5))
	}
}
