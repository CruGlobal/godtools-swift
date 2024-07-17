//
//  VideoViewCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import YouTubeiOSPlayerHelper

class VideoViewCoordinator: NSObject {
    
    private let videoPlayerDidBecomeReady: ((_ playerView: YTPlayerView) -> Void)?
    private let videoStateChanged: ((_ playerView: YTPlayerView, _ playerState: YTPlayerState) -> Void)?
        
    init(videoPlayerDidBecomeReady: ((_ playerView: YTPlayerView) -> Void)?, videoStateChanged: ((_ playerView: YTPlayerView, _ playerState: YTPlayerState) -> Void)?) {
        
        self.videoPlayerDidBecomeReady = videoPlayerDidBecomeReady
        self.videoStateChanged = videoStateChanged
        
        super.init()
    }
}

extension VideoViewCoordinator: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        videoPlayerDidBecomeReady?(playerView)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        videoStateChanged?(playerView, state)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
    }
}
