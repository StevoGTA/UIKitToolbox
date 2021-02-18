//
//  UKTDRMInfo.swift
//  UIKit Toolbox
//
//  Created by Stevo on 1/13/21.
//  Copyright © 2021 Sunset Magicwerks, LLC. All rights reserved.
//

import AVKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTDRMInfo
struct UKTDRMInfo {

	// MARK: Types
	typealias Proc = (_ drmInfo :UKTDRMInfo?, _ error :Error?) -> Void
	typealias QueryProc = (_ preferWidevine :Bool, _ completionProc :@escaping Proc) -> Void

	// MARK: Properties
	let	contentKeySession: AVContentKeySession?

	let	widevineLicenseURL :URL?
	let	widevineLicenseHeaders :[String : String]?

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	init() {
		// Nothing
		self.contentKeySession = nil

		self.widevineLicenseURL = nil
		self.widevineLicenseHeaders = nil
	}

	//------------------------------------------------------------------------------------------------------------------
	init(contentKeySession :AVContentKeySession?) {
		// Store
		self.contentKeySession = contentKeySession

		self.widevineLicenseURL = nil
		self.widevineLicenseHeaders = nil
	}

	//------------------------------------------------------------------------------------------------------------------
	init(widevineLicenseURL :URL, widevineLicenseHeaders :[String : String] = [:]) {
		// Store
		self.contentKeySession = nil

		self.widevineLicenseURL = widevineLicenseURL
		self.widevineLicenseHeaders = widevineLicenseHeaders
	}
}
