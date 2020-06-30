//
//  UIFont+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/21/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIFont extension
extension UIFont {

	// MARK: Properties
	var	weight :UIFont.Weight {
				// Setup
				guard let traits = self.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey : Any]
						else { return .regular }
				guard let weight = traits[.weight] as? NSNumber else { return .regular }

				return UIFont.Weight(rawValue: CGFloat(weight.doubleValue))
			}

	var	monospacedDigitSystemFont :UIFont
			{ UIFont.monospacedDigitSystemFont(ofSize: self.pointSize, weight: self.weight) }
}
