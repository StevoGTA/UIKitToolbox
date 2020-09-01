//
//  CGPDFDocument+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 5/7/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: CGPDFDocument extension
extension CGPDFDocument {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func data(forPages indexSet :IndexSet) -> Data {
		// Setup
		let	data = NSMutableData()

		// Run lean
		autoreleasepool() {
			// Setup
			UIGraphicsBeginPDFContextToData(data, .zero, nil)

			// Iterate page indexes
			indexSet.forEach() {
				// Setup
				guard let page = self.page(at: $0 + 1) else { return }

				// Add page
				let	boxRect = page.getBoxRect(.mediaBox)
				UIGraphicsBeginPDFPageWithInfo(boxRect, nil)

				let	context = UIGraphicsGetCurrentContext()!
				context.interpolationQuality = .high
				context.saveGState()
				context.scaleBy(x: 1.0, y: -1.0)
				context.translateBy(x: 0.0, y: -boxRect.height)
				context.drawPDFPage(page)
				context.restoreGState()
			}

			// Cleanup
			UIGraphicsEndPDFContext()
		}

		return data as Data
	}

	//------------------------------------------------------------------------------------------------------------------
	func image(for page :Int) -> UIImage? {
		// Preflight
		guard let page = self.page(at: page + 1) else { return nil }

		// Setup
		var	image :UIImage? = nil

		// Run lean
		autoreleasepool() {
			// Setup
			let	boxRect = page.getBoxRect(.mediaBox)
			UIGraphicsBeginImageContext(boxRect.size)

			let	context = UIGraphicsGetCurrentContext()!
			context.interpolationQuality = .high
			context.saveGState()
			context.scaleBy(x: 1.0, y: -1.0)
			context.translateBy(x: 0.0, y: -boxRect.height)
			context.drawPDFPage(page)
			context.restoreGState()

			// Cleanup
			image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
		}

		return image
	}
}
