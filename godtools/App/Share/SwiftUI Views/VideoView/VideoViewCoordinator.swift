//
//  VideoViewCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import YouTubeiOSPlayerHelper

class VideoViewCoordinator: NSObject, YTPlayerViewDelegate {
    
    private let videoView: VideoView
    
    init(videoView: VideoView) {
        
        self.videoView = videoView
        
        super.init()
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        videoView.videoPlayerViewDidBecomeReady()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        if state == .playing {
            videoView.videoPlaying()
        }
        
        if state == .ended {
            videoView.videoEnded()
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
    }
}
