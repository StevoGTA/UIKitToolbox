//
//  UIImage+Extensions.swift
//  Virtual Sheet Music
//
//  Created by Stevo on 4/9/20.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIImage extensions
extension UIImage {

	// MARK: Class methods
	//------------------------------------------------------------------------------------------------------------------
	static func from(_ data :Data?) -> UIImage? { (data != nil) ? UIImage(data: data!) : nil }
}
