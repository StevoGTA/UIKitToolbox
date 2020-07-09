//
//  CGImage+Extensions.swift
//  Swift Toolbox
//
//  Created by Stevo on 7/7/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import CoreGraphics
import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: CGImage extension
extension CGImage {

	// MARK: Types
	enum DataType {
		case nonLossyAlpha
		case nonLossyNoAlpha
		case lossyAlpha(compressionQuality :CGFloat)
		case lossyNoAlpha(compressionQuality :CGFloat)
	}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func data(dataType :DataType = .nonLossyAlpha) -> Data {
		// Check type
		switch dataType {
			case .nonLossyAlpha, .nonLossyNoAlpha, .lossyAlpha(_):
				// PNG
				return UIImage(cgImage: self).pngData()!

			case .lossyNoAlpha(let compressionQuality):
				// JPEG
				return UIImage(cgImage: self).jpegData(compressionQuality: compressionQuality)!
		}
	}
}
