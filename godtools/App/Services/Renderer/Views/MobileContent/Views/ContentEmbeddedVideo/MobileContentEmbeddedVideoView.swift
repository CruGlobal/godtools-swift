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
    private let loadingContainerView: UIView = UIView()
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: MobileContentEmbeddedVideoViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
                
        setupLayout()
        
        setLoadingViewHidden(hidden: false, animated: false)
        
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
        
        let parentView: UIView = self
        
        // videoView
        videoView.backgroundColor = .clear
        parentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.constrainEdgesToView(view: parentView)
        
        // loadingContainerView
        loadingContainerView.backgroundColor = ColorPalette.gtLightestGrey.uiColor
        parentView.addSubview(loadingContainerView)
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.constrainEdgesToView(view: parentView)
        
        // loadingView
        loadingView.hidesWhenStopped = false
        loadingContainerView.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.constrainCenterHorizontallyInView(view: parentView)
        loadingView.constrainCenterVerticallyInView(view: parentView)
        loadingView.color = .white
    }
    
    private func setLoadingViewHidden(hidden: Bool, animated: Bool) {
        
        let videoView: MobileContentEmbeddedVideoView = self
        let loadingViewAlpha: CGFloat = hidden ? 0 : 1
        
        hidden ? loadingView.stopAnimating() : loadingView.startAnimating()
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                videoView.loadingContainerView.alpha = loadingViewAlpha
            } completion: { (finished: Bool) in
                if finished && hidden {
                    videoView.loadingView.stopAnimating()
                }
            }

        }
        else {
            loadingContainerView.alpha = loadingViewAlpha
        }
    }
    
    // MARK: - MobileContentView
    
    override func viewDidDisappear() {

        videoView.currentTime({ [weak self] (number: Float, error: Error?) in
            self?.viewModel.trackElapsedTime(elapsedTime: number)
        })
        
        videoView.pauseVideo()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .setToAspectRatioOfProvidedSize(size: CGSize(width: 16, height: 9))
    }
}

// MARK: - YTPlayerViewDelegate

extension MobileContentEmbeddedVideoView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        if let lastTrackedElapsedTime = viewModel.getLastTrackedElapsedTime() {
            videoView.cueVideo(byId: viewModel.videoId, startSeconds: lastTrackedElapsedTime)
        }
        
        setLoadingViewHidden(hidden: true, animated: true)
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
