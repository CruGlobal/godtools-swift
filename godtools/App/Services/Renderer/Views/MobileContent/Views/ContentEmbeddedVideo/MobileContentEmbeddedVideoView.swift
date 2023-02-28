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
    
    private let viewModel: MobileContentEmbeddedVideoViewModel
    private let videoView: YTPlayerView = YTPlayerView()
    
    init(viewModel: MobileContentEmbeddedVideoViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
                
        setupLayout()
        
        videoView.delegate = self
        videoView.load(withVideoId: viewModel.videoId, playerVars: viewModel.youtubePlayerParameters)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
                
        videoView.delegate = nil
        videoView.webView?.uiDelegate = nil
        videoView.webView?.navigationDelegate = nil
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
    
    // MARK: - MobileContentView
    
    override func viewDidDisappear() {

        videoView.stopVideo()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .setToAspectRatioOfProvidedSize(size: CGSize(width: 16, height: 9))
    }
}


// MARK: - YTPlayerViewDelegate

extension MobileContentEmbeddedVideoView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
    }
    
    internal func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        if state == .ended {
            videoView.cueVideo(byId: viewModel.videoId, startSeconds: 0.0)
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {

    }
}

