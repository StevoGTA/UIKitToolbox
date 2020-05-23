//
//  UKTImageCache.swift
//  UIKit Toolbox
//
//  Created by Stevo on 5/8/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTImageCache
protocol UKTImageCache : DataCache {}

extension UKTImageCache {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func image(for identifier :String) throws -> UIImage? { UIImage.from(try? data(for: identifier)) }
}

//----------------------------------------------------------------------------------------------------------------------
// MARK - UKTMemoryImageCache
class UKTMemoryImageCache : MemoryDataCache, UKTImageCache {}

//----------------------------------------------------------------------------------------------------------------------
// MARK - UKTFilesystemImageCache
class UKTFilesystemImageCache : FilesystemDataCache, UKTImageCache {}
