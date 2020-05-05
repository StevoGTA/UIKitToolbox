//
//  UKTRemoteImageRetriever.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/20/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTRemoteImageRetriever
protocol UKTRemoteImageRetriever {

	// MARK: Instance methods
	func queryRemoteImage(for item :Any, completionProc :@escaping (_ image :UIImage) -> Void)
	func cancelQueryRemoteImage(for item :Any)
}
