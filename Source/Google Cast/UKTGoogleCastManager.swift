//
//  UKTGoogleCastManager.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/1/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import GoogleCast

//----------------------------------------------------------------------------------------------------------------------
// MARK: Notifications
extension Notification.Name {
	/*
		Sent when the session state has changed.
			object is UKTGoogleCastManager
	*/
	static	public	let	googleCastManagerCastSessionStateChanged =
								Notification.Name("googleCastManagerCastSessionStateChanged")
}

//----------------------------------------------------------------------------------------------------------------------
// MARK: - UKTGoogleCastManager
class UKTGoogleCastManager : NSObject, GCKLoggerDelegate, GCKSessionManagerListener {

	// MARK: Properties
	static			let	shared = UKTGoogleCastManager()

					var	hasCurrentSession :Bool { GCKCastContext.sharedInstance().sessionManager.currentSession != nil }
					var	currentCastDeviceName :String?
								{ GCKCastContext.sharedInstance().sessionManager.currentSession?.device.friendlyName }

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	override init() {
		// Do super
		super.init()

		// Setup Google Cast
		let	discoveryCriteria = GCKDiscoveryCriteria(applicationID: kGCKDefaultMediaReceiverApplicationID)

		let	castOptions = GCKCastOptions(discoveryCriteria: discoveryCriteria)
		castOptions.physicalVolumeButtonsWillControlDeviceVolume = true

		GCKCastContext.setSharedInstanceWith(castOptions)
		GCKCastContext.sharedInstance().sessionManager.add(self)
		GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true

#if DEBUG
		GCKLogger.sharedInstance().delegate = self
#endif
	}

	// MARK: GCKLoggerDelegate methods
	//------------------------------------------------------------------------------------------------------------------
	func logMessage(_ message :String, at level :GCKLoggerLevel, fromFunction function :String, location :String) {
		// Log
		NSLog("\(function) - \(message)")
	}

	// MARK: GCKSessionManagerListener methods
	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, willStart session :GCKSession) {
		// Log
		NSLog("Google Cast will start session")
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, didStart session :GCKSession) {
		// Log
		NSLog("Google Cast did start session")

		// Post notification
		NotificationCenter.default.post(name: .googleCastManagerCastSessionStateChanged, object: self)
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, didFailToStart session :GCKSession,
			withError error :Error) {
		// Log
		NSLog("Google Cast did fail to start session with error \(error)")
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, didSuspend session :GCKSession,
			with reason :GCKConnectionSuspendReason) {
		// Log
		NSLog("Google Cast did suspend session with reason \(reason)")

		// Post notification
		NotificationCenter.default.post(name: .googleCastManagerCastSessionStateChanged, object: self)
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, willResumeSession session :GCKSession) {
		// Log
		NSLog("Google Cast will resume session")
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, didResumeSession session :GCKSession) {
		// Log
		NSLog("Google Cast did resume session")

		// Post notification
		NotificationCenter.default.post(name: .googleCastManagerCastSessionStateChanged, object: self)
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, willEnd session :GCKSession) {
		// Log
		NSLog("Google Cast will end session")
	}

	//------------------------------------------------------------------------------------------------------------------
	func sessionManager(_ sessionManager :GCKSessionManager, didEnd session :GCKSession, withError error :Error?) {
		if error == nil {
			NSLog("Google Cast did end session")
		} else {
			NSLog("Google Cast did end session with error \(error!)")
		}

		// Post notification
		NotificationCenter.default.post(name: .googleCastManagerCastSessionStateChanged, object: self)
	}
}
