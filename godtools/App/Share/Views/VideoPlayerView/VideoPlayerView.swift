//
//  VideoPlayerView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoPlayerView: UIViewController {
    
    @IBOutlet weak private var youTubeVideoPlayer: YTPlayerView!
    @IBOutlet weak private var youTubeVideoPlayerLoadingView: UIView!
    @IBOutlet weak private var youTubeVideoPlayerActivityIndicator: UIActivityIndicatorView!
    
    private var viewModel: VideoPlayerViewModelType
    
    required init(viewModel: VideoPlayerViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: VideoPlayerView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var youtubePlayerParameters: [String : Any]? {
        let playsInFullScreen = 0
        
        return ["playsinline": playsInFullScreen]
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadYoutubePlayerVideo(videoId: viewModel.youtubeVideoId)
    }
    
    private func loadYoutubePlayerVideo(videoId: String) {
        
        let hidesYouTubeVideoPlayer: Bool
        
        if !viewModel.youtubeVideoId.isEmpty {
            hidesYouTubeVideoPlayer = false
            youTubeVideoPlayerActivityIndicator.startAnimating()
            youTubeVideoPlayer.delegate = self
            youTubeVideoPlayer.load(withVideoId: viewModel.youtubeVideoId, playerVars: youtubePlayerParameters)
        }
        else {
            hidesYouTubeVideoPlayer = true
            youTubeVideoPlayer.stopVideo()
            youTubeVideoPlayer.delegate = nil
            youTubeVideoPlayerActivityIndicator.stopAnimating()
        }

        youTubeVideoPlayer.isHidden = hidesYouTubeVideoPlayer
        youTubeVideoPlayerLoadingView.isHidden = hidesYouTubeVideoPlayer
        
        playVideo()
    }
    
    private func playVideo() {
        youTubeVideoPlayer.playVideo()
    }
    
    private func stopVideo() {
        youTubeVideoPlayer.stopVideo()
    }
}

// MARK: - YTPlayerViewDelegate

extension VideoPlayerView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.youTubeVideoPlayerLoadingView.alpha = 0
        }) { [weak self] (finished: Bool) in
            self?.youTubeVideoPlayerLoadingView.isHidden = true
            self?.youTubeVideoPlayerLoadingView.alpha = 1
            self?.youTubeVideoPlayerActivityIndicator.stopAnimating()
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        print("\n ToolDetailView playerView didChangeTo state")
        switch state {
            
        case .unstarted:
            print("unstarted")
        case .ended:
            print("ended")
            viewModel.videoEnded()
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
        print("\n ToolDetailView playerView didChangeTo quality")
    }
    
    func playerView(_ playerView: YTPlayerError, receivedError error: YTPlayerError) {
        print("\n TutorialCell: youTubeVideoPlayer receivedError")
        print("  error: \(error)")
    }
}
