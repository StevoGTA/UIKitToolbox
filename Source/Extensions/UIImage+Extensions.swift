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

	//------------------------------------------------------------------------------------------------------------------
	static func from(_ cgImage :CGImage?) -> UIImage? { (cgImage != nil) ? UIImage(cgImage: cgImage!) : nil }

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func aspectCroppedImageSize(for size :CGSize) -> CGSize {
		// Calculate scale factors
		let	wScale = size.width / self.size.width;
		let	hScale = size.height / self.size.height;

		return (wScale > hScale) ?
				CGSize(width: size.width, height: self.size.height * wScale) :
				CGSize(width: self.size.width * hScale, height: size.height)
	}

	//------------------------------------------------------------------------------------------------------------------
	func aspectCroppedImage(for size :CGSize) -> UIImage {
		// Get aspect-scaled size
		let	scaledSize = self.aspectCroppedImageSize(for: size)
		let	rect =
					CGRect(x: (size.width - scaledSize.width) * 0.5, y: (size.height - scaledSize.height) * 0.5,
							width: scaledSize.width, height: scaledSize.height)

		// Create new image
		UIGraphicsBeginImageContext(size);
		draw(in: rect)
		let	newImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext();

		return newImage
	}

	//------------------------------------------------------------------------------------------------------------------
	func draw(centeredAt point :CGPoint) {
		// Setup
		let	size = self.size;

		// Draw
		draw(at: point.offsetBy(dx: -size.width * 0.5, dy: -size.height * 0.5))
	}
}
