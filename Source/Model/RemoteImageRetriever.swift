//
//  RemoteImageRetriever.swift
//  Media Player - Apple
//
//  Created by Stevo on 4/20/20.
//  Copyright © 2020 Sunset Magicwerks, LLC. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: RemoteImageRetriever
protocol RemoteImageRetriever {

	// MARK: Instance methods
	func queryRemoteImage(for item :Any, completionProc :@escaping (_ image :UIImage) -> Void)
	func cancelQueryRemoteImage(for item :Any)
}
