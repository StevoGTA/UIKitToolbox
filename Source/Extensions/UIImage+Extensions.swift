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
}
