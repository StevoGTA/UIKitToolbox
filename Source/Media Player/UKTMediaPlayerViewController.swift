//
//  UKTMediaPlayerViewController.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/27/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import AVFoundation
import UIKit

#if !targetEnvironment(macCatalyst)
	import GoogleCast
#endif

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTMediaPlayerViewController
class UKTMediaPlayerViewController : UKTViewController {

	// MARK: Types
	enum ControlMode {
		case full
		case none
	}

	enum Action {
		case none
		case playPause
		case goToBeginning
		case goToEnd
		case rewind
		case forward
		case audio
	}

	enum TimeDelta {
		// MARK: Values
		case _10s
		case _15s
		case _30s
		case _45s
		case _60s
		case _75s
		case _90s

		// MARK: Properties
		var	timeInterval :TimeInterval {
					// What is the value
					switch self {
						case ._10s:	return 10.0
						case ._15s:	return 15.0
						case ._30s:	return 30.0
						case ._45s:	return 45.0
						case ._60s:	return 60.0
						case ._75s:	return 75.0
						case ._90s:	return 90.0
					}
				}
	}

	struct QueueItem {

		// MARK: Properties
		let	mediaPlayable :UKTMediaPlayable
		let	startOffsetTimeInterval :TimeInterval

		// MARK: Lifecycle methods
		init(mediaPlayable :UKTMediaPlayable, startOffsetTimeInterval :TimeInterval = 0.0) {
			// Store
			self.mediaPlayable = mediaPlayable
			self.startOffsetTimeInterval = startOffsetTimeInterval
		}
	}

	// MARK: Properties
#if !targetEnvironment(macCatalyst)
	static				var	googleCastManager :UKTGoogleCastManager?
#endif

						var	action1 = Action.goToBeginning
								{ didSet { setup(actionButton: self.actionButton1, action: self.action1) } }
						var	action2 = Action.rewind
								{ didSet { setup(actionButton: self.actionButton2, action: self.action2) } }
						var	action3 = Action.playPause
								{ didSet { setup(actionButton: self.actionButton3, action: self.action3) } }
						var	action4 = Action.forward
								{ didSet { setup(actionButton: self.actionButton4, action: self.action4) } }
						var	action5 = Action.audio
								{ didSet { setup(actionButton: self.actionButton5, action: self.action5) } }

						var	rewindTimeDelta = TimeDelta._10s
						var	forwardTimeDelta = TimeDelta._10s

						var	posterImageInfoProc
									:(_ queueItem :QueueItem) ->
											(t :Any, remoteImageRetriever :UKTRemoteImageRetriever)? = { _ in return nil }
						var	infoProc :(_ queueItem :QueueItem) -> String? = { _ in return nil }
						var	mediaPlayablePlayerCurrentPositionUpdatedProc :(_ currentPosition :TimeInterval) -> Void = { _ in }
						var	closeProc :() -> Void = {}

			@IBOutlet	var	posterImageView :UKTRemoteImageImageView!
			@IBOutlet	var	posterImageOverlayView :UIVisualEffectView!

			@IBOutlet	var	videoView :UIView!

			@IBOutlet	var	activityIndicatorView :UIActivityIndicatorView!

			@IBOutlet	var	controlsView :UIView!
			@IBOutlet	var	titleLabel :UILabel!
			@IBOutlet	var	infoLabel :UILabel!
			@IBOutlet	var	castingMessageLabel :UILabel!
			@IBOutlet	var	positionSlider :UISlider!
			@IBOutlet	var	leadingTimeLabel :UILabel!
			@IBOutlet	var	trailingTimeLabel :UILabel!
			@IBOutlet	var	actionButton1 :UIButton!
			@IBOutlet	var	actionButton2 :UIButton!
			@IBOutlet	var	actionButton3 :UIButton!
			@IBOutlet	var	actionButton4 :UIButton!
			@IBOutlet	var	actionButton5 :UIButton!

			private		var	controlMode = ControlMode.full

			private		var	queueItems :[QueueItem]!
			private		var	currentQueueItem :QueueItem?
			private		var	currentQueueItemDuration :TimeInterval?
			private		var	currentQueueItemDRMInfo :UKTDRMInfo?

			private		var	queryDRMInfoProc :UKTDRMInfo.QueryProc?

			private		var	mediaPlayablePlayer :UKTMediaPlayablePlayer!
			private		var	mediaPlayablePlayerIsPlaying = false
			private		var	mediaPlayablePlayerCurrentPosition :TimeInterval = 0.0
			private		var	mediaPlayablePlayerCurrentVolume :Float?
			private		var	mediaPlayablePlayerIsMuted :Bool?
			private		var	mediaPlayablePlayerCanHideControls = false
			private		var	mediaPlayablePlayerLayer :CALayer?

			private		var	positionIsChanging = false

	// MARK: Class methods
	//------------------------------------------------------------------------------------------------------------------
	static func instantiate(with queueItems :[QueueItem], autoplay :Bool = true, controlMode :ControlMode = .full,
			queryDRMInfoProc :UKTDRMInfo.QueryProc? = nil) -> UKTMediaPlayerViewController {
		// Setup
		let	mediaPlayerViewController =
					UIStoryboard.init(name: "UKTMediaPlayerView", bundle: nil).instantiateInitialViewController() as!
							UKTMediaPlayerViewController
		mediaPlayerViewController.controlMode = controlMode
		mediaPlayerViewController.queueItems = queueItems
		mediaPlayerViewController.mediaPlayablePlayerIsPlaying = autoplay
		mediaPlayerViewController.queryDRMInfoProc = queryDRMInfoProc

		return mediaPlayerViewController
	}

	// MARK: UIViewController methods
	//------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {
		// Do super
		super.viewDidLoad()

		// Setup Notifications
#if !targetEnvironment(macCatalyst)
		addNotificationObserver(forName: .googleCastManagerCastSessionStateChanged) { [unowned self] _ in
			// Change media player
			self.prepareCurrentQueueItem()
		}
#endif

		// Setup UI
		if self.controlMode == .none {
			// Hide all controls
			self.posterImageView.isHidden = true
			self.posterImageOverlayView.isHidden = true
			self.controlsView.isHidden = true
		}

		setup(actionButton: self.actionButton1, action: self.action1)
		setup(actionButton: self.actionButton2, action: self.action2)
		setup(actionButton: self.actionButton3, action: self.action3)
		setup(actionButton: self.actionButton4, action: self.action4)
		setup(actionButton: self.actionButton5, action: self.action5)

		// Start first Media Playable
		playNextQueueItem()
	}

	//------------------------------------------------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {
		// Do super
		super.viewDidLayoutSubviews()

		// Update media player layer frame
		self.mediaPlayablePlayerLayer?.frame = self.videoView.bounds

//		// Check if need to update controls
//		if self.mediaPlayablePlayerCanHideControls {
//			// Setup
//			let	aspectRatio = self.view.bounds.size.aspectRatio
//
//			// Check if need to update controls
//			if (aspectRatio > 1.0) && (self.controlsView.alpha > 0.0) {
//				// Hide controls
//				toggleControlsVisibility()
//			} else if (aspectRatio < 1.0) && (self.controlsView.alpha < 1.0) {
//				// Show controls
//				toggleControlsVisibility()
//			}
//		}
	}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func seek(to timeInterval :TimeInterval) {
		// Make sure we're loaded
		_ = self.view

		// Seek
		self.mediaPlayablePlayer.seek(timeInterval: timeInterval)
	}

	// MARK: IBAction methods
	//------------------------------------------------------------------------------------------------------------------
	@IBAction func toggleControlsVisibility(_ :UITapGestureRecognizer) {
		// Ensure controls can be hidden
		guard self.mediaPlayablePlayerCanHideControls else { return }
		guard self.controlMode == .full else { return }

		// Show/hide
		toggleControlsVisibility()
	}

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func close(_ :UIButton) { self.closeProc() }

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func positionWillChange(_ :UISlider) { self.positionIsChanging = true }

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func positionChanged(_ :UISlider) {
		// Update UI
		updateCurrentPositionUI(value: TimeInterval(self.positionSlider.value))
	}

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func positionDidChange(_ :UISlider) {
		// Seek
		self.mediaPlayablePlayerCurrentPosition = TimeInterval(self.positionSlider.value)
		self.positionIsChanging = false

		// Seek
		self.mediaPlayablePlayer.seek(timeInterval: self.mediaPlayablePlayerCurrentPosition)
	}

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func positionChangeCancel(_ :UISlider) {
		// No longer changing
		self.positionIsChanging = false

		// Update UI
		updateCurrentPositionUI(value: self.mediaPlayablePlayerCurrentPosition)
	}

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func action1(_ :UIButton!) { perform(action: self.action1) }

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func action2(_ :UIButton!) { perform(action: self.action2) }

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func action3(_ :UIButton!) { perform(action: self.action3) }

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func action4(_ :UIButton!) { perform(action: self.action4) }

	//------------------------------------------------------------------------------------------------------------------
	@IBAction func action5(_ :UIButton!) { perform(action: self.action5) }

	// MARK: Private methods
	//------------------------------------------------------------------------------------------------------------------
	private func playNextQueueItem() {
		// See if we have another queue item
		guard !self.queueItems.isEmpty else {
			// No more queue items
			self.closeProc()

			return
		}

		// Update current queue item
		self.currentQueueItem = self.queueItems.removeFirst()
		self.currentQueueItemDuration = nil

		// Setup Media Player
		self.mediaPlayablePlayerIsPlaying = true
		self.mediaPlayablePlayerCurrentPosition = self.currentQueueItem!.startOffsetTimeInterval
		prepareCurrentQueueItem()

		// Update UI
		self.titleLabel.text = self.currentQueueItem!.mediaPlayable.title
		self.infoLabel.text = self.infoProc(self.currentQueueItem!)

		if let info = self.posterImageInfoProc(self.currentQueueItem!) {
			// Setup Poster Image View
			self.posterImageView.setup(with: info.t, remoteImageRetriever: info.remoteImageRetriever)
		} else {
			// No poster image
			self.posterImageView.cleanup()
			self.posterImageView.image = nil
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	private func prepareCurrentQueueItem() {
		// Stop current media player
		self.mediaPlayablePlayer = nil

		self.mediaPlayablePlayerLayer?.removeFromSuperlayer()
		self.mediaPlayablePlayerLayer = nil

		// Check if need to query DRM info
		if let queryDRMInfoProc = self.queryDRMInfoProc {
			// Yes
			self.activityIndicatorView.startAnimating()
			self.controlsView.alpha = 0.0

			// Query DRM info
			queryDRMInfoProc(type(of: self).googleCastManager?.hasCurrentSession ?? false) { [weak self] in
				// Handle results
				self?.currentQueueItemDRMInfo = $0

				// Update UI
				self?.activityIndicatorView.stopAnimating()
				self?.controlsView.alpha = 1.0

				// Check error
				if $1 == nil {
					// Setup media Player
					self?.setupMediaPlayer()
				} else {
					// Present error
					self?.presentAlert($1!,
							actionProc: {
								// Check queue
								if !(self?.queueItems.isEmpty ?? true) {
									// Play next item
									self?.playNextQueueItem()
								} else {
									// Dismiss
									self?.dismissAnimated()
								}
							})
				}
			}
		} else {
			// No
			setupMediaPlayer()
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	private func setupMediaPlayer() {
		// Setup media player
#if !targetEnvironment(macCatalyst)
		if let googleCastManager = type(of: self).googleCastManager, googleCastManager.hasCurrentSession {
			// Try to use Google Cast
			do {
				// Setup
				self.mediaPlayablePlayer =
						try UKTGoogleCastMediaPlayer(mediaPlayable: self.currentQueueItem!.mediaPlayable,
								autoplay: self.mediaPlayablePlayerIsPlaying,
								startOffsetTimeInterval: self.mediaPlayablePlayerCurrentPosition,
								drmInfo: self.currentQueueItemDRMInfo)
				self.castingMessageLabel.text = "Casting to \(googleCastManager.currentCastDeviceName!)"
				self.mediaPlayablePlayerCanHideControls = false
			} catch {
				// Error
				NSLog("UKTMediaPlayerViewController encountered error when setting up Google Cast: \(error)")
			}
		}

		if self.mediaPlayablePlayer == nil {
			// Use AVFoundation
			self.mediaPlayablePlayer =
					try! UKTAVMediaPlayer(mediaPlayable: self.currentQueueItem!.mediaPlayable,
							autoplay: self.mediaPlayablePlayerIsPlaying,
							startOffsetTimeInterval: self.mediaPlayablePlayerCurrentPosition,
							drmInfo: self.currentQueueItemDRMInfo)

			self.mediaPlayablePlayerLayer = (self.mediaPlayablePlayer as! UKTAVMediaPlayer).layer
			self.mediaPlayablePlayerLayer!.frame = self.videoView.bounds
			self.videoView.layer.addSublayer(self.mediaPlayablePlayerLayer!)

			self.castingMessageLabel.text = ""
			self.mediaPlayablePlayerCanHideControls = true
		}
#else
		// Use AVFoundation
		self.mediaPlayablePlayer =
				try! UKTAVMediaPlayer(mediaPlayable: self.currentQueueItem!.mediaPlayable,
						autoplay: self.mediaPlayablePlayerIsPlaying,
						startOffsetTimeInterval: self.mediaPlayablePlayerCurrentPosition, drmInfo: self.drmInfo)

		self.mediaPlayablePlayerLayer = (self.mediaPlayablePlayer as! UKTAVMediaPlayer).layer
		self.mediaPlayablePlayerLayer!.frame = self.videoView.bounds
		self.videoView.layer.addSublayer(self.mediaPlayablePlayerLayer!)

		self.castingMessageLabel.text = ""
		self.mediaPlayablePlayerCanHideControls = true
#endif

		// Setup Media Player
		self.mediaPlayablePlayer.noteActivityProc = { [unowned self] in
			// Update UI
			if $0 {
				// Activity
				self.activityIndicatorView.startAnimating()
			} else {
				// No activity
				self.activityIndicatorView.stopAnimating()
			}
		}
		self.mediaPlayablePlayer.noteErrorProc = { [unowned self] error, shouldClose in
			// Present error
			self.presentAlert(error, actionProc: { if shouldClose { self.dismissAnimated() } })
		}
		self.mediaPlayablePlayer.notePlaybackInfoProc = { [unowned self] in
			// Store
			self.currentQueueItemDuration = $0

			self.mediaPlayablePlayerIsPlaying = $2
			self.mediaPlayablePlayerCurrentPosition = $1
			self.mediaPlayablePlayerCurrentVolume = $3
			self.mediaPlayablePlayerIsMuted = $4

			// Update UI
			self.updateActionUI()
			self.updatePositionUI()

			// Call proc
			self.mediaPlayablePlayerCurrentPositionUpdatedProc(self.mediaPlayablePlayerCurrentPosition)
		}
		self.mediaPlayablePlayer.playbackCompleteProc = { [unowned self] in
			// Cleanup
			self.currentQueueItem = nil
			self.mediaPlayablePlayer = nil

			// Play next Media Playable
			self.playNextQueueItem()
		}

		// Update UI
		updateActionUI()
		updatePositionUI()
	}

	//------------------------------------------------------------------------------------------------------------------
	private func setup(actionButton :UIButton, action :Action) {
		// Check action
		switch action {
			case .none:
				// None
				actionButton.setBackgroundImage(nil, for: .normal)

			case .playPause:
				// Play/Pause
				actionButton.setBackgroundImage(
						UIImage.init(systemName: self.mediaPlayablePlayerIsPlaying ? "pause.circle" : "play.circle"),
						for: .normal)

			case .goToBeginning:
				// Go to beginning
				actionButton.setBackgroundImage(UIImage.init(systemName: "backward.end"), for: .normal)

			case .goToEnd:
				// Go to end
				actionButton.setBackgroundImage(UIImage.init(systemName: "forward.end"), for: .normal)

			case .rewind:
				// Rewind
				switch self.rewindTimeDelta {
					case ._10s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.10"), for: .normal)
					case ._15s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.15"), for: .normal)
					case ._30s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.30"), for: .normal)
					case ._45s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.45"), for: .normal)
					case ._60s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.60"), for: .normal)
					case ._75s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.75"), for: .normal)
					case ._90s:	actionButton.setBackgroundImage(UIImage.init(systemName: "gobackward.90"), for: .normal)
				}

			case .forward:
				// Forward
				switch self.forwardTimeDelta {
					case ._10s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.10"), for: .normal)
					case ._15s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.15"), for: .normal)
					case ._30s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.30"), for: .normal)
					case ._45s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.45"), for: .normal)
					case ._60s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.60"), for: .normal)
					case ._75s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.75"), for: .normal)
					case ._90s:	actionButton.setBackgroundImage(UIImage.init(systemName: "goforward.90"), for: .normal)
				}

			case .audio:
				// Audio
				if self.mediaPlayablePlayer is UKTAVMediaPlayer {
					// Not available for AVFoundation playback
					actionButton.setBackgroundImage(nil, for: .normal)
				} else if self.mediaPlayablePlayerIsMuted ?? false {
					// Muted
					actionButton.setBackgroundImage(UIImage.init(systemName: "speaker.slash"), for: .normal)
				} else if (self.mediaPlayablePlayerCurrentVolume ?? 0.4) < 0.25 {
					// Volume lowest
					actionButton.setBackgroundImage(UIImage.init(systemName: "speaker"), for: .normal)
				} else if (self.mediaPlayablePlayerCurrentVolume ?? 0.4) < 0.5 {
					// Volume medium-low
					actionButton.setBackgroundImage(UIImage.init(systemName: "speaker.1"), for: .normal)
				} else if (self.mediaPlayablePlayerCurrentVolume ?? 0.4) < 0.75 {
					// Volume medium-high
					actionButton.setBackgroundImage(UIImage.init(systemName: "speaker.2"), for: .normal)
				} else {
					// Volume highest
					actionButton.setBackgroundImage(UIImage.init(systemName: "speaker.3"), for: .normal)
				}
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	private func perform(action :Action) {
		// Check action
		switch action {
			case .none:	break

			case .playPause:
				// Play/Pause
				if self.mediaPlayablePlayerIsPlaying {
					// Pause
					self.mediaPlayablePlayer.pause()
				} else {
					// Play
					self.mediaPlayablePlayer.play()
				}

			case .goToBeginning:
				// Go to beginning
				self.mediaPlayablePlayer.goToBegining()

			case .goToEnd:
				// Go to end
				self.mediaPlayablePlayer.goToEnd()

			case .rewind:
				// Rewind
				self.mediaPlayablePlayer.rewind(timeInterval: self.rewindTimeDelta.timeInterval)

			case .forward:
				// Forward
				self.mediaPlayablePlayer.forward(timeInterval: self.forwardTimeDelta.timeInterval)

			case .audio:
				// Audio
				if !(self.mediaPlayablePlayer is UKTAVMediaPlayer) {
// TODO: Audio action
				}
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	private func updateActionUI() {
		// Update UI
		if self.action1 == .playPause { setup(actionButton: self.actionButton1, action: .playPause) }
		if self.action2 == .playPause { setup(actionButton: self.actionButton2, action: .playPause) }
		if self.action3 == .playPause { setup(actionButton: self.actionButton3, action: .playPause) }
		if self.action4 == .playPause { setup(actionButton: self.actionButton4, action: .playPause) }
		if self.action5 == .playPause { setup(actionButton: self.actionButton5, action: .playPause) }

		if self.action1 == .audio { setup(actionButton: self.actionButton1, action: .audio) }
		if self.action2 == .audio { setup(actionButton: self.actionButton2, action: .audio) }
		if self.action3 == .audio { setup(actionButton: self.actionButton3, action: .audio) }
		if self.action4 == .audio { setup(actionButton: self.actionButton4, action: .audio) }
		if self.action5 == .audio { setup(actionButton: self.actionButton5, action: .audio) }
	}

	//------------------------------------------------------------------------------------------------------------------
	private func toggleControlsVisibility() {
		// Check if showing or hiding
		if self.controlsView.alpha > 0.0 {
			// Hide
			UIView.animate(withDuration: 0.3, animations: {
				// Fade alpha
				self.posterImageView.alpha = 0.0
				self.controlsView.alpha = 0.0
			}) { _ in
				// Toggle overlay
				self.posterImageOverlayView.isHidden = true
			}
		} else {
			// Show
			self.posterImageOverlayView.isHidden = false
			UIView.animate(withDuration: 0.3) {
				// Fade alpha
				self.posterImageView.alpha = 1.0
				self.controlsView.alpha = 1.0
			}
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	private func updatePositionUI() {
		// Check for values
		if let duration = self.currentQueueItemDuration {
			// Update slider
			self.positionSlider.isHidden = false
			self.positionSlider.maximumValue = Float(duration)

			// Check duration
			self.leadingTimeLabel.isHidden = false
			self.trailingTimeLabel.isHidden = false

			if duration >= 1.0 * 60.0 * 60.0 {
				// An hour or longer
				self.trailingTimeLabel.text = String(for: duration, using: .hoursMinutesSeconds)
			} else {
				// Less than an hour
				self.trailingTimeLabel.text = String(for: duration, using: .minutesSeconds)
			}

			// Check if changing position
			if !self.positionIsChanging {
				// Update current position UI
				self.positionSlider.value = Float(self.mediaPlayablePlayerCurrentPosition)
				updateCurrentPositionUI(value: self.mediaPlayablePlayerCurrentPosition)
			}
		} else {
			// No values
			self.positionSlider.isHidden = true
			self.leadingTimeLabel.isHidden = true
			self.trailingTimeLabel.isHidden = true
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	private func updateCurrentPositionUI(value :TimeInterval) {
		// Update UI
		if value >= 1.0 * 60.0 * 60.0 {
			// An hour or longer
			self.leadingTimeLabel.text = String(for: value, using: .hoursMinutesSeconds)
		} else {
			// Less than an hour
			self.leadingTimeLabel.text = String(for: value, using: .minutesSeconds)
		}
	}
}
