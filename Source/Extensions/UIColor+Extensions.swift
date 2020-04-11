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
	var	asString :String {
				// Setup
				var	r :CGFloat = 0.0
				var	g :CGFloat = 0.0
				var	b :CGFloat = 0.0
				var	a :CGFloat = 0.0
				getRed(&r, green: &g, blue: &b, alpha: &a)

				return "rgba:\(r),\(g),\(b),\(a)"
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
}
