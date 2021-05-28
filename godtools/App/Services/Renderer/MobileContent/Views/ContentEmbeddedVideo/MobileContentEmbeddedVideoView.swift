//
//  MobileContentEmbeddedVideoView.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class MobileContentEmbeddedVideoView: MobileContentView, YTPlayerViewDelegate {
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
        
        videoView.backgroundColor = .magenta
        videoView.drawBorder()
    }
    
    private func setupBinding() {
        
        embedVideo()
    }
    
    private func embedVideo() {
        
        //guard let videoId = viewModel.videoId else { return }
        
        //videoView.delegate = self
        //videoView.load(withVideoId: videoId, playerVars: viewModel.youtubePlayerParameters)
                
        addSubview(videoView)
        
        videoView.constrainEdgesToSuperview()
        
        /*videoView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: videoView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: videoView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: videoView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        addConstraint(leading)
        addConstraint(trailing)
        addConstraint(top)*/
        
        /*let height: NSLayoutConstraint = NSLayoutConstraint(
            item: videoView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 300
        )
        
        height.priority = UILayoutPriority(1000)
        
        videoView.addConstraint(height)*/
        /*let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
            item: videoView,
            attribute: .height,
            relatedBy: .equal,
            toItem: videoView,
            attribute: .width,
            multiplier: CGFloat(1.0),
            constant: 0
        )
        
        videoView.addConstraint(aspectRatio)*/
    }
    
    // MARK: - MobileContentView

    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .equalToHeight(height: 300)
    }
}


// MARK: - YTPlayerViewDelegate

/*extension ToolDetailView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        print("\n ToolDetailView player view did become ready")
        
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerView) {
        
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
        case .queued:
            print("queued")
        case .unknown:
            print("unknown")
        @unknown default:
            print("default")
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        
        print("\n ToolDetailView playerView didChangeTo quality")
        
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: WKYTPlayerError) {
        
        print("\n ToolDetailView playerView receivedError error")
        print("  error: \(error)")
        
    }
}*/

