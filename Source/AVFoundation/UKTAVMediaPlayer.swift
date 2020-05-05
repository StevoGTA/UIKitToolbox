//
//  UKTAVMediaPlayer.swift
//  UIKit Toolbox
//
//  Created by Stevo on 5/1/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import AVFoundation
import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTAVMediaPlayer
class UKTAVMediaPlayer : NSObject, UKTMediaPlayablePlayer {

	// MARK: Properties
			var	layer :CALayer { self.avPlayerLayer }

			var	noteActivityProc :(_ activity :Bool) -> Void = { _ in }
			var	noteErrorProc :(_ error :Error, _ shouldClose :Bool) -> Void = { _,_ in }
			var	notePlaybackInfoProc
						:(_ duration :TimeInterval?, _ currentPosition :TimeInterval, _ isPlaying :Bool,
								_ volume :Float, _ isMuted :Bool) -> Void = { _,_,_,_,_ in }
			var	playbackCompleteProc :() -> Void = {}

	private	let	avPlayer :AVPlayer
	private	let	avPlayerLayer :AVPlayerLayer

	private	var	notificationObservers = [NSObjectProtocol]()

	// MARK: Lifecycle methods
	//------------------------------------------------------------------------------------------------------------------
	required init(mediaPlayable :UKTMediaPlayable, autoplay :Bool, startOffsetTimeInterval :TimeInterval) throws {
		// Setup
		self.avPlayer = AVPlayer(url: mediaPlayable.url)

		self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)

		// Do super
		super.init()

		// Setup notifications
		addNotificationObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
				{ [unowned self] _ in self.playbackCompleteProc() }
		addNotificationObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: self.avPlayer.currentItem)
				{ [unowned self] _ in self.noteErrorProc(self.avPlayer.currentItem!.error!, true) }
		self.avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: nil)
				{ [weak self] in
					// Ensure we are still around
					guard let strongSelf = self else { return }

					// Call proc
					strongSelf.notePlaybackInfoProc(
							strongSelf.avPlayer.currentItem!.duration.isNumeric ?
									strongSelf.avPlayer.currentItem!.duration.seconds : 0.0,
							$0.seconds, strongSelf.avPlayer.timeControlStatus == .playing, 0.5, false)
				}
		self.avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)

		// Seek
		self.avPlayer.seek(to: CMTime(seconds: startOffsetTimeInterval, preferredTimescale: 600),
				toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)

		// Check autoplay
		if autoplay {
			// Play
			self.avPlayer.play()
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	deinit {
		// Cleanup
		self.notificationObservers.forEach() { NotificationCenter.default.removeObserver($0) }
		self.avPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
	}

	// MARK: UKTMediaPlayablePlayer methods
	//------------------------------------------------------------------------------------------------------------------
	func play() { self.avPlayer.play() }

	//------------------------------------------------------------------------------------------------------------------
	func pause() { self.avPlayer.pause() }

	//------------------------------------------------------------------------------------------------------------------
	func goToBegining() { self.avPlayer.seek(to: CMTime.zero) }

	//------------------------------------------------------------------------------------------------------------------
	func goToEnd() { seek(to: self.avPlayer.currentItem!.duration) }

	//------------------------------------------------------------------------------------------------------------------
	func rewind(timeInterval :TimeInterval) {
		// Rewind
		seek(to: CMTimeSubtract(self.avPlayer.currentTime(), CMTime(seconds: timeInterval, preferredTimescale: 600)))
	}

	//------------------------------------------------------------------------------------------------------------------
	func forward(timeInterval :TimeInterval) {
		// Forward
		seek(to: CMTimeAdd(self.avPlayer.currentTime(), CMTime(seconds: timeInterval, preferredTimescale: 600)))
	}

	//------------------------------------------------------------------------------------------------------------------
	func seek(timeInterval :TimeInterval) { seek(to: CMTime(seconds: timeInterval, preferredTimescale: 600)) }

	// MARK: Key/Value Observering methods
	//------------------------------------------------------------------------------------------------------------------
	override func observeValue(forKeyPath keyPath :String?, of object :Any?, change :[NSKeyValueChangeKey : Any]?,
			context :UnsafeMutableRawPointer?) {
		// Check keyPath
		if keyPath == "timeControlStatus" {
			// Time Control Status
			if let oldValue = change?[NSKeyValueChangeKey.oldKey] as? Int,
					let newValue = change?[NSKeyValueChangeKey.newKey] as? Int, oldValue != newValue {
				// Setup
				let newTimeControlStatus = AVPlayer.TimeControlStatus(rawValue: newValue)

				// Call proc
				self.noteActivityProc((newTimeControlStatus != .playing) && (newTimeControlStatus != .paused))
			}
		}
	}

	// MARK: Private methods
	//------------------------------------------------------------------------------------------------------------------
	private func addNotificationObserver(forName name :NSNotification.Name, object :Any? = nil,
			queue :OperationQueue? = nil, proc :@escaping (Notification) -> Void) {
		// Add
		self.notificationObservers.append(
				NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: proc))
	}

	//------------------------------------------------------------------------------------------------------------------
	private func seek(to cmTime :CMTime) {
		// Seek
		self.avPlayer.seek(to: cmTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
	}
}
