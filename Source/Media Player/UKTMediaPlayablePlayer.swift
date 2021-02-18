//
//  UKTMediaPlayablePlayer.swift
//  UIKit Toolbox
//
//  Created by Stevo on 4/27/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import AVFoundation
import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: UKTMediaPlayablePlayer
protocol UKTMediaPlayablePlayer {

	// MARK: Properties
	var	noteActivityProc :(_ activity :Bool) -> Void { get set }
	var	noteErrorProc :(_ error :Error, _ shouldClose :Bool) -> Void { get set }
	var	notePlaybackInfoProc
				:(_ duration :TimeInterval?, _ currentPosition :TimeInterval, _ isPlaying :Bool, _ volume :Float,
						_ isMuted :Bool) -> Void { get set }
	var	playbackCompleteProc :() -> Void { get set }

	// MARK: Lifecycle methods
	init(mediaPlayable :UKTMediaPlayable, autoplay :Bool, startOffsetTimeInterval :TimeInterval, drmInfo :UKTDRMInfo?)
			throws

	// MARK: Instance methods
	func play()
	func pause()
	func goToBegining()
	func goToEnd()
	func rewind(timeInterval :TimeInterval)
	func forward(timeInterval :TimeInterval)
	func seek(timeInterval :TimeInterval)

	func setAudio(muted :Bool)
	func setAudio(volume :Float)
}
