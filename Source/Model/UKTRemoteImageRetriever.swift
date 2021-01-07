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
	func image(for item :Any, size :CGSize, aspectFit :Bool) -> UIImage?
	func retrieveRemoteImage(for item :Any, size :CGSize, aspectFit :Bool,
			completionProc :@escaping (_ image :UIImage?, _ error :Error?) -> Void) -> String?
	func cancelRetrieveRemoteImage(for identifier :String)
}
