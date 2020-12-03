//
//  UKTMediaPlayable.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/27/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTMediaPlayable
protocol UKTMediaPlayable {

	// MARK: Properties
	var	identifier :String { get }
	var	title :String { get }
	var	description :String? { get }
	var	url :URL { get }
}
