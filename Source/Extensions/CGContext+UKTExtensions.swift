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

	//------------------------------------------------------------------------------------------------------------------
	func draw(touches :[UITouch], in view :UIView, color :UIColor = .black, blendMode :CGBlendMode = .normal,
			nonPencilLineWidth :CGFloat, scale :CGFloat = UIScreen.main.scale,
			pointTransformProc :(_ touchPoint :CGPoint) -> CGPoint) {
		// Setup
		saveGState()

		setStrokeColor(color.cgColor)
		setLineCap(.round)
		setBlendMode(blendMode)

		// Iterate touches
		touches.forEach() {
			// Setup
			let	fromPoint = pointTransformProc($0.previousLocation(in: view))
			let	toPoint = pointTransformProc($0.location(in: view))

			// Check touch type
			if $0.type == .pencil {
				// Stylus drawing
				if ($0.altitudeAngle < CGFloat(.pi / 6.0)) {	// 30º
					// Setup for shading
					// Get angle
					let	azimuthUnitVector = $0.azimuthUnitVector(in: view)
					let	touchMovedVector = CGVector(from: fromPoint, to: toPoint)
					var	angle =
								abs(atan2(touchMovedVector.dy, touchMovedVector.dx) -
										atan2(azimuthUnitVector.dy, azimuthUnitVector.dx))
					if angle > .pi { angle = 2.0 * .pi - angle }
					if angle > (.pi / 2.0) { angle = .pi - angle }

					let	normalizedAngle = angle / (.pi / 2.0)

					// Get altitude
					let	altitudeAngle = max(0.25, $0.altitudeAngle)

					let	normalizedAltitudeConstant :CGFloat = .pi / 6.0 - 0.25
					let	normalizedAltitude :CGFloat = 1.0 - ((altitudeAngle - 0.25) / normalizedAltitudeConstant)

					// Set line width
					setLineWidth((60.0 * normalizedAngle * normalizedAltitude + 5.0) * scale)

					// Update alpha based on force
					let	normalizedAlpha = $0.force / 5.0
					setAlpha(normalizedAlpha)
				} else {
					// Setup for drawing
					setLineWidth(($0.force > 0.0) ? $0.force * 4.0 : nonPencilLineWidth * scale)
					setAlpha(1.0)
				}
			} else {
				// Direct drawing
				setLineWidth(nonPencilLineWidth * scale)
				setAlpha(1.0)
			}

			// Draw path
			beginPath()
			move(to: CGPoint(x: fromPoint.x * scale, y: fromPoint.y * scale))
			addLine(to: CGPoint(x: toPoint.x * scale, y: toPoint.y * scale))
			strokePath()
		}

		// Restore
		restoreGState()
	}
}
