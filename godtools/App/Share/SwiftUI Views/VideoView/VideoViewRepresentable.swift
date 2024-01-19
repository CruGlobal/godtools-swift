//
//  VideoViewRepresentable.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import YouTubeiOSPlayerHelper

struct VideoViewRepresentable: UIViewRepresentable {
    
    private let videoId: String
    private let videoPlayerParameters: [String: Any]?
    private let configuration: VideoViewConfiguration?
    
    private let containerView: UIView
    private let youtubePlayerView: YTPlayerView
    private let loadingView: UIView
    private let loadingActivityIndicator: UIActivityIndicatorView
    private let videoPlayingClosure: (() -> Void)?
    private let videoEndedClosure: (() -> Void)?
    
    @Binding var playerState: VideoViewPlayerState
    
    init(playerState: Binding<VideoViewPlayerState>, frameSize: CGSize, videoId: String, videoPlayerParameters: [String: Any]?, configuration: VideoViewConfiguration?, videoPlayingClosure: (() -> Void)?, videoEndedClosure: (() -> Void)?) {
        
        let bounds: CGRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        self._playerState = playerState
        self.videoId = videoId
        self.videoPlayerParameters = videoPlayerParameters
        self.configuration = configuration
        self.videoPlayingClosure = videoPlayingClosure
        self.videoEndedClosure = videoEndedClosure
        
        containerView = UIView(frame: bounds)
        youtubePlayerView = YTPlayerView(frame: bounds)
        loadingView = UIView(frame: bounds)
        loadingActivityIndicator = UIActivityIndicatorView(style: .medium)
        
        setupLayout()
    }
    
    private func setupLayout() {
        
        containerView.addSubview(youtubePlayerView)
        containerView.addSubview(loadingView)
        loadingView.addSubview(loadingActivityIndicator)
        
        containerView.backgroundColor = UIColor(configuration?.videoContainerBackgroundColor ?? ColorPalette.gtLightestGrey.color)
        youtubePlayerView.backgroundColor = UIColor(configuration?.videoBackgroundColor ?? .white)
        loadingView.backgroundColor = UIColor(configuration?.loadingViewBackgroundColor ?? ColorPalette.gtLightestGrey.color)
        
        loadingActivityIndicator.layer.position = CGPoint(
            x: loadingView.frame.size.width / 2,
            y: loadingView.frame.size.height / 2
        )
        loadingActivityIndicator.color = UIColor(configuration?.loadingActivityIndicatorColor ?? .white)
    }
    
    private func setLoadingViewHidden(hidden: Bool, animated: Bool) {
        
        let loadingViewAlpha: CGFloat = hidden ? 0 : 1
        
        hidden ? loadingActivityIndicator.stopAnimating() : loadingActivityIndicator.startAnimating()
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                //animations
                self.loadingView.alpha = loadingViewAlpha
            } completion: { (finished: Bool) in
                if finished && hidden {
                    self.loadingActivityIndicator.stopAnimating()
                }
            }

        }
        else {
            loadingView.alpha = loadingViewAlpha
        }
    }
    
    private func updatePlayerState() {
        
        switch playerState {
        
        case .paused:
            youtubePlayerView.pauseVideo()
        
        case .playing:
            youtubePlayerView.playVideo()
        
        case .stopped:
            youtubePlayerView.stopVideo()
        }
    }
    
    func makeCoordinator() -> VideoViewCoordinator {
        return VideoViewCoordinator(videoView: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        
        youtubePlayerView.delegate = context.coordinator
        youtubePlayerView.load(withVideoId: videoId, playerVars: videoPlayerParameters)
        setLoadingViewHidden(hidden: false, animated: false)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        updatePlayerState()
    }
    
    func play() {
        youtubePlayerView.playVideo()
    }
    
    func pause() {
        youtubePlayerView.pauseVideo()
    }
    
    func stop() {
        youtubePlayerView.stopVideo()
    }
}

extension VideoViewRepresentable {
    
    func videoPlayerViewDidBecomeReady() {
        
        setLoadingViewHidden(hidden: true, animated: true)
        
        updatePlayerState()
    }
    
    func videoPlaying() {
        videoPlayingClosure?()
    }
    
    func videoEnded() {
        videoEndedClosure?()
    }
}
