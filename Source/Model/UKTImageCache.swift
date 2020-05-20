//
//  UKTImageCache.swift
//  UIKit Toolbox
//
//  Created by Stevo on 5/8/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: ImageCache
protocol ImageCache : DataCache {}

extension ImageCache {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func image(for identifier :String) throws -> UIImage? { UIImage.from(try? data(for: identifier)) }
}

//----------------------------------------------------------------------------------------------------------------------
// MARK - MemoryImageCache
class MemoryImageCache : MemoryDataCache, ImageCache {}

//----------------------------------------------------------------------------------------------------------------------
// MARK - MemoryImageCache
class FilesystemImageCache : FilesystemDataCache, ImageCache {}
