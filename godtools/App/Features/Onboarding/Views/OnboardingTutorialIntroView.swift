//
//  OnboardingTutorialIntroView.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class OnboardingTutorialIntroView: UIView, NibBased {
    
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var videoButton: UIButton!
    @IBOutlet weak private var youTubeVideoPlayer: YTPlayerView!
    
    private var viewModel: OnboardingTutorialIntroViewModelType?
    
    required init() {
        super.init(frame: UIScreen.main.bounds)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    var youtubePlayerParameters: [String : Any]? {
        let playsInFullScreen = 0
        
        return ["playsinline": playsInFullScreen]
    }
    
    func configure(viewModel: OnboardingTutorialIntroViewModelType) {

        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title

        logoImageView.image = viewModel.logoImage
        
        loadYoutubePlayerVideo(videoId: viewModel.youtubeVideoId)
        
        setupBinding()
    }
    
    private func setupBinding() {
        
        videoButton.addTarget(self, action: #selector(videoLinkTapped(button:)), for: .touchUpInside)
    }
    
    @objc private func videoLinkTapped (button: UIButton) {
        
        youTubeVideoPlayer.playVideo()
        
        viewModel?.videoLinkTapped()
    }
    
    private func loadYoutubePlayerVideo(videoId: String) {
        
        youTubeVideoPlayer.delegate = self
        youTubeVideoPlayer.load(withVideoId: videoId, playerVars: youtubePlayerParameters)
        youTubeVideoPlayer.isHidden = true
    }
    
    private func recueVideo() {
        
        guard let youtubeVideoId = viewModel?.youtubeVideoId else { return }
        
        youTubeVideoPlayer.cueVideo(byId: youtubeVideoId, startSeconds: 0.0)
    }
}

// MARK: - YTPlayerViewDelegate

extension OnboardingTutorialIntroView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        print("\n ToolDetailView player view did become ready")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        print("\n ToolDetailView playerView didChangeTo state")
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
        
        if state == .ended, let youTubePlayerId = viewModel?.youtubeVideoId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.loadYoutubePlayerVideo(videoId: youTubePlayerId)
            }
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
    
        print("\n ToolDetailView playerView didChangeTo quality")
    }
    
    func playerView(_ playerView: YTPlayerError, receivedError error: YTPlayerError) {
        print("\n TutorialCell: youTubeVideoPlayer receivedError")
        print("  error: \(error)")
    }
}
