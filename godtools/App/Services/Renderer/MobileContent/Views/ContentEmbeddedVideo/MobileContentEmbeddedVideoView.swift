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
    
    required init(viewModel: MobileContentImageViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        videoView.backgroundColor = .clear
    }
    
    private func setupBinding() {
        
        embedVideo()
    }
    
    private func embedVideo() {
        
        videoView.load(withVideoId: viewModel.videoId, playerVars: viewModel.youtubePlayerParameters)
                
        addSubview(videoView)
        
        videoView.constrainEdgesToSuperview()
        
        let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
            item: videoView,
            attribute: .height,
            relatedBy: .equal,
            toItem: videoView,
            attribute: .width,
            multiplier: CGFloat(1.0),
            constant: 0
        )
        
        videoView.addConstraint(aspectRatio)
    }
    
    // MARK: - MobileContentView

    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}
