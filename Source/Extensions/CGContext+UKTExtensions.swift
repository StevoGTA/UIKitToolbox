//
//  CGContext+Extensions.swift
//  Virtual Sheet Music
//
//  Created by Stevo on 6/17/20.
//

import CoreGraphics

//----------------------------------------------------------------------------------------------------------------------
// MARK: CGContext extension
extension CGContext {

	// Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func draw(string :String, color :UIColor, font :UIFont, at center :CGPoint) {
		// Setup
		let	paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center

		let	attributedString =
					NSAttributedString(string: string,
							attributes: [
											.foregroundColor: color,
											.paragraphStyle: paragraphStyle,
											.font: font,
										])

		let	framesetter = CTFramesetterCreateWithAttributedString(attributedString)
		let	frameSize =
					CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
							CFRange(location: 0, length: attributedString.length), nil,
							CGSize(width: .max, height: .max), nil)

		var	rect =
					CGRect(x: center.x - frameSize.width * 0.5,
							y: center.y - frameSize.height * 0.5, width: frameSize.width,
							height: frameSize.height)

		// Setup path
		rect.origin.y = rect.origin.y - (rect.size.height - frameSize.height) * 0.5

		let	path = CGPath(rect: rect, transform: nil)
		let	frame =
					CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attributedString.length), path,
							nil)

		// Must flip the context to draw the text correctly
		saveGState()
		translateBy(x: 0.0, y: rect.origin.y * 2.0 + rect.size.height)
		scaleBy(x: 1.0, y: -1.0)

		// Draw text
		CTFrameDraw(frame, self)

		// Cleanjup
		restoreGState()
	}
}
