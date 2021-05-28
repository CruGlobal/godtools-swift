//
//  MobileContentEmbeddedVideoView.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class MobileContentEmbeddedVideoView: MobileContentView {
    private let viewModel: MobileContentEmbeddedVideoViewModelType
    private let videoView: YTPlayerView = YTPlayerView()
    
    required init(viewModel: MobileContentEmbeddedVideoViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        videoView.stopVideo()
    }
    
    private func setupLayout() {
        
        videoView.backgroundColor = .clear
    }
    
    private func setupBinding() {
        
        embedVideo()
    }
    
    private func embedVideo() {
                
        addSubview(videoView)
        
        videoView.constrainEdgesToSuperview()
        
        videoView.delegate = self
        videoView.load(withVideoId: viewModel.videoId, playerVars: viewModel.youtubePlayerParameters)
    }
    
    // MARK: - MobileContentView

    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .equalToHeight(height: 300)
    }
}


// MARK: - YTPlayerViewDelegate

extension MobileContentEmbeddedVideoView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        print("\n ToolDetailView player view did become ready")
    }
    
    internal func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        print("\n ToolDetailView playerView didChangeTo state")
        
        switch state {
            
        case .unstarted:
            print("unstarted")
        case .ended:
            print("ended")
        case .playing:
            print("playing")
        case .paused:
            print("paused")
        case .buffering:
            print("buffering")
        case .cued:
            print("cued")
        case .unknown:
            print("unknown")
        @unknown default:
            print("default")
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        
        print("\n ToolDetailView playerView didChangeTo quality \(quality)")
        
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
        print("\n ToolDetailView playerView receivedError: \(error)")
    }
}

