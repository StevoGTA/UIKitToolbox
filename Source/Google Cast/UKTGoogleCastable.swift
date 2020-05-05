//
//  UKTGoogleCastable.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/23/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTGoogleCastable
protocol UKTGoogleCastable : UKTMediaPlayable {

	// MARK: Properties
	var	subtitle :String { get }
	var	posterURL :URL? { get }
}
