//
//  MobileContentEmbeddedVideoView.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import YouTubeiOSPlayerHelper

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
        
        // videoView
        videoView.backgroundColor = .clear
        let parentView: UIView = self
        parentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.constrainEdgesToView(view: parentView)
    }
    
    private func setupBinding() {
        
        embedVideo()
    }
    
    private func embedVideo() {
        
        videoView.delegate = self
        videoView.load(withVideoId: viewModel.videoId, playerVars: viewModel.youtubePlayerParameters)
    }
    
    private func recueVideo() {
        
        videoView.cueVideo(byId: viewModel.videoId, startSeconds: 0.0)
    }
    
    // MARK: - MobileContentView
    
    override func viewDidDisappear() {
        videoView.pauseVideo()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .setToAspectRatioOfProvidedSize(size: CGSize(width: 16, height: 9))
    }
}


// MARK: - YTPlayerViewDelegate

extension MobileContentEmbeddedVideoView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        print("\n MobileContentEmbeddedVideoView player view did become ready")
    }
    
    internal func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        print("\n MobileContentEmbeddedVideoView playerView didChangeTo state")
        
        switch state {
            
        case .unstarted:
            print("unstarted")
        case .ended:
            print("ended")
            recueVideo()
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
        
        print("\n MobileContentEmbeddedVideoView playerView didChangeTo quality \(quality)")
        
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
        print("\n MobileContentEmbeddedVideoView playerView receivedError: \(error)")
    }
}

