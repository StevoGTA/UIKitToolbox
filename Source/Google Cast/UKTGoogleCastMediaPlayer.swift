//
//  UKTGoogleCastMediaPlayer.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/27/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

#if !targetEnvironment(macCatalyst)

import AVFoundation
import Foundation
import GoogleCast

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTGoogleCastMediaPlayerError
enum UKTGoogleCastMediaPlayerError : Error {
	case noCurrentSession
	case cannotPlayRemoteMedia
	case invalidMediaPlayable
}

extension UKTGoogleCastMediaPlayerError : LocalizedError {

	// MARK: Properties
	public	var	errorDescription :String? {
						// What are we
						switch self {
							case .noCurrentSession:	return "No current session"
							case .cannotPlayRemoteMedia: return "Cannot play remote media"
							case .invalidMediaPlayable: return "Invalid content"
						}
					}
}

//----------------------------------------------------------------------------------------------------------------------
// MARK: - UKTGoogleCastMediaPlayer
class UKTGoogleCastMediaPlayer : NSObject, UKTMediaPlayablePlayer, GCKRemoteMediaClientListener, GCKRequestDelegate {

	// MARK: Properties
			var	noteActivityProc :(_ activity :Bool) -> Void = { _ in }
			var	noteErrorProc :(_ error :Error, _ shouldClose :Bool) -> Void = { _,_ in }
			var	notePlaybackInfoProc
						:(_ duration :TimeInterval?, _ currentPosition :TimeInterval, _ isPlaying :Bool,
								_ volume :Float, _ isMuted :Bool) -> Void = { _,_,_,_,_ in }
			var	playbackCompleteProc :() -> Void = {}

	private	let	googleCastable :UKTGoogleCastable
	private	let	remoteMediaClient :GCKRemoteMediaClient

	private	var	playbackInfoTimer :Timer!

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	required init(mediaPlayable :UKTMediaPlayable, autoplay :Bool, startOffsetTimeInterval :TimeInterval,
			drmInfo :UKTDRMInfo?) throws {
		// Setup
		guard let session = GCKCastContext.sharedInstance().sessionManager.currentSession else
				{ throw UKTGoogleCastMediaPlayerError.noCurrentSession }
		guard let remoteMediaClient = session.remoteMediaClient else
				{ throw UKTGoogleCastMediaPlayerError.cannotPlayRemoteMedia }
		guard let googleCastable = mediaPlayable as? UKTGoogleCastable else
				{ throw UKTGoogleCastMediaPlayerError.invalidMediaPlayable }

		// Store
		self.googleCastable = googleCastable
		self.remoteMediaClient = remoteMediaClient

		// Do super
		super.init()

		// Setup timer
		self.playbackInfoTimer =
				Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
						{ [unowned self] _ in self.updatePlaybackInfo() }

		// Wait a tick
		DispatchQueue.main.async() { [weak self] in
			// Ensure we are still active
			guard let strongSelf = self else { return }

			// Note activity
			strongSelf.noteActivityProc(true)

			// Setup
			strongSelf.remoteMediaClient.add(strongSelf)

			let	metadata = GCKMediaMetadata()
			metadata.setString(strongSelf.googleCastable.title, forKey: kGCKMetadataKeyTitle)
			metadata.setString(strongSelf.googleCastable.subtitle, forKey: kGCKMetadataKeyTitle)
			if let posterURL = strongSelf.googleCastable.posterURL {
				// Add image
				metadata.addImage(GCKImage(url: posterURL, width: 0, height: 0))
			}

			let	url = strongSelf.googleCastable.url
			let	mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url)
//			mediaInfoBuilder.streamType = url.absoluteString.hasSuffix("mp4") ? .buffered : .live
			mediaInfoBuilder.streamType = .buffered
//			mediaInfoBuilder.streamType = .none
//			mediaInfoBuilder.contentType = url.absoluteString.hasSuffix("mp4") ? "video/mp4" : "video/m3u"
			mediaInfoBuilder.contentType = "video/mp4"
			mediaInfoBuilder.metadata = metadata

			var	customData = [String : Any]()
			customData["licenseURL"] = drmInfo?.widevineLicenseURL?.absoluteString
			customData["licenseHeaders"] = drmInfo?.widevineLicenseHeaders
			mediaInfoBuilder.customData = customData

			// Build
			let mediaInformation = mediaInfoBuilder.build()

			// Load
			let	options = GCKMediaLoadOptions()
			options.autoplay = autoplay
			options.playPosition = startOffsetTimeInterval

			let	request = strongSelf.remoteMediaClient.loadMedia(mediaInformation, with: options)
			request.delegate = strongSelf
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	deinit {
		// Stop
		self.remoteMediaClient.remove(self)
		self.remoteMediaClient.stop()

		// Cleanup
		self.playbackInfoTimer.invalidate()
	}

	// MARK: GCKRemoteMediaClientListener methods
	//------------------------------------------------------------------------------------------------------------------
	func remoteMediaClient(_ remoteMediaClient :GCKRemoteMediaClient, didUpdate mediaStatus :GCKMediaStatus?) {
		// Ensure we have media status
		guard mediaStatus != nil else { return }

		// Check status
		switch mediaStatus!.playerState {
			case .unknown:	break
			case .idle:
				// Idle
				self.noteActivityProc(false)

				if mediaStatus!.idleReason == .finished {
					// Finished
					self.playbackCompleteProc()
				}

			case .playing, .paused:
				// Playing
				self.noteActivityProc(false)

				self.updatePlaybackInfo()

			case .buffering:
				// Buffering
				self.noteActivityProc(true)

			case .loading:
				// Loading
				self.noteActivityProc(true)

			@unknown default:	fatalError("Unhandled GCKMediaPlayerState case \(mediaStatus!.playerState)")
		}

		if (mediaStatus!.playerState == .idle) && (mediaStatus!.idleReason == .finished) {
			// Finished
			self.playbackCompleteProc()
		}
	}

	// MARK: GCKRequestDelegate methods
	//------------------------------------------------------------------------------------------------------------------
	func requestDidComplete(_ request :GCKRequest) {}

	//------------------------------------------------------------------------------------------------------------------
	func request(_ request :GCKRequest, didFailWithError error :GCKError) { self.noteErrorProc(error, true) }

	//------------------------------------------------------------------------------------------------------------------
	func request(_ request :GCKRequest, didAbortWith abortReason :GCKRequestAbortReason) {
// TODO: GCKRequest didAbortWith
	}

	// MARK: UKTMediaPlayablePlayer methods
	//------------------------------------------------------------------------------------------------------------------
	func play() { self.remoteMediaClient.play() }

	//------------------------------------------------------------------------------------------------------------------
	func pause() { self.remoteMediaClient.pause() }

	//------------------------------------------------------------------------------------------------------------------
	func goToBegining() { self.remoteMediaClient.seek(with: GCKMediaSeekOptions()) }

	//------------------------------------------------------------------------------------------------------------------
	func goToEnd() {
		// Go to end
		let	mediaSeekOptions = GCKMediaSeekOptions()
		mediaSeekOptions.seekToInfinite = true
		self.remoteMediaClient.seek(with: mediaSeekOptions)
	}

	//------------------------------------------------------------------------------------------------------------------
	func rewind(timeInterval :TimeInterval) {
		// Rewind
		let	mediaSeekOptions = GCKMediaSeekOptions()
		mediaSeekOptions.interval = -timeInterval
		mediaSeekOptions.relative = true
		self.remoteMediaClient.seek(with: mediaSeekOptions)
	}

	//------------------------------------------------------------------------------------------------------------------
	func forward(timeInterval :TimeInterval) {
		// Forward
		let	mediaSeekOptions = GCKMediaSeekOptions()
		mediaSeekOptions.interval = timeInterval
		mediaSeekOptions.relative = true
		self.remoteMediaClient.seek(with: mediaSeekOptions)
	}

	//------------------------------------------------------------------------------------------------------------------
	func seek(timeInterval :TimeInterval) {
		// Seek
		let	mediaSeekOptions = GCKMediaSeekOptions()
		mediaSeekOptions.interval = timeInterval
		self.remoteMediaClient.seek(with: mediaSeekOptions)
	}

	//------------------------------------------------------------------------------------------------------------------
	func setAudio(muted :Bool) {
// TODO: setAudio muted
	}

	//------------------------------------------------------------------------------------------------------------------
	func setAudio(volume :Float) {
// TODO: setAudio volume
	}

	// MARK: Private methods
	//------------------------------------------------------------------------------------------------------------------
	private func updatePlaybackInfo() {
		// Query current media status
		guard let mediaStatus = self.remoteMediaClient.mediaStatus else { return }
		let	playerState = mediaStatus.playerState
		guard (playerState == .playing) || (playerState == .paused) else { return }

		// Call proc
		self.notePlaybackInfoProc(mediaStatus.mediaInformation?.streamDuration,
				self.remoteMediaClient.approximateStreamPosition(), playerState == .playing, mediaStatus.volume,
				mediaStatus.isMuted)
	}
}

#endif
