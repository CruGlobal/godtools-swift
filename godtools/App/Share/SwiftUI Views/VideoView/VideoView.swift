//
//  VideoView.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import youtube_ios_player_helper

struct VideoView: UIViewRepresentable {
    
    private let videoId: String
    private let videoPlayerParameters: [String: Any]?
    
    private let containerView: UIView
    private let youtubePlayerView: YTPlayerView
    private let loadingView: UIView
    private let loadingActivityIndicator: UIActivityIndicatorView
    
    init(frameSize: CGSize, videoId: String, videoPlayerParameters: [String: Any]?) {
        
        let bounds: CGRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        self.videoId = videoId
        self.videoPlayerParameters = videoPlayerParameters
        
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
        
        containerView.backgroundColor = ColorPalette.media.uiColor
        youtubePlayerView.backgroundColor = .white
        loadingView.backgroundColor = ColorPalette.media.uiColor
        
        loadingActivityIndicator.layer.position = CGPoint(
            x: loadingView.frame.size.width / 2,
            y: loadingView.frame.size.height / 2
        )
        loadingActivityIndicator.color = .white
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
        
    }
    
    func setLoadingViewHidden(hidden: Bool, animated: Bool) {
        
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
