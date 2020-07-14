//
//  UIColor+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/9/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIColor extensions
extension UIColor {

	// MARK: Properties
	var	rgba :(red :CGFloat, green :CGFloat, blue :CGFloat, alpha :CGFloat) {
				// Setup
				var	red :CGFloat = 0.0
				var	green :CGFloat = 0.0
				var	blue :CGFloat = 0.0
				var	alpha :CGFloat = 0.0
				getRed(&red, green: &green, blue: &blue, alpha: &alpha)

				return (red, green, blue, alpha)
			}
	var	asString :String {
				// Setup
				let	(red, green, blue, alpha) = self.rgba

				return "rgba:\(red),\(green),\(blue),\(alpha)"
			}

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	convenience init?(_ string :String?) {
		// Preflight
		guard string != nil else { return nil }

		// Decompose components
		let	fields = string!.components(separatedBy: ":")
		guard fields.count == 2 else { return nil }
		if fields[0] == "rgba" {
			// RGBA
			let	components = fields[1].components(separatedBy: ",")

			self.init(red: CGFloat(components[0])!, green: CGFloat(components[1])!, blue: CGFloat(components[2])!,
					alpha: CGFloat(components[3])!)
		} else {
			// Unknown
			return nil
		}
	}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func rgbaEquals(_ other :UIColor) -> Bool {
		// Get info
		let	(red, green, blue, alpha) = self.rgba
		let	(otherRed, otherGreen, otherBlue, otherAlpha) = other.rgba

		return (red == otherRed) && (green == otherGreen) && (blue == otherBlue) && (alpha == otherAlpha)
	}
}
