//
//  UIFont+Extensions.swift
//  Media Player - Apple
//
//  Created by Stevo on 4/21/20.
//  Copyright © 2020 Sunset Magicwerks, LLC. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIFont extension
extension UIFont {

	// MARK: Properties
	var	weight :UIFont.Weight {
				//
				guard let traits = self.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey : Any]
						else { return .regular }
				guard let weight = traits[.weight] as? NSNumber else { return .regular }

				return UIFont.Weight(rawValue: CGFloat(weight.doubleValue))
			}

	var	monospacedDigitSystemFont :UIFont
			{ UIFont.monospacedDigitSystemFont(ofSize: self.pointSize, weight: self.weight) }
}
