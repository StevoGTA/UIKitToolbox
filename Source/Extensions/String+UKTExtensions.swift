//
//  String+UKTExtensions.swift
//  Virtual Sheet Music
//
//  Created by Stevo on 6/19/20.
//

//----------------------------------------------------------------------------------------------------------------------
// MARK: String UIKit Toolbox extension
extension String {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func size(with font :UIFont) -> CGSize {
		// Return size
		return self.size(
				withAttributes: [
									.font: font,
								])
	}
}
