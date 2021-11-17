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
    
    private let viewModel: VideoPlayerViewModelType
    
    private var closeButton: UIBarButtonItem?
    
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
        let disablesFullScreen = 1
        
        return ["playsinline": disablesFullScreen]
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadYoutubePlayerVideo(videoId: viewModel.youtubeVideoId)
        
        closeButton = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.image,
            color: UIColor.white,
            target: self,
            action: #selector(handleClose)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        youTubeVideoPlayer.playVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        youTubeVideoPlayer.pauseVideo()
    }
    
    private func loadYoutubePlayerVideo(videoId: String) {
        
        youTubeVideoPlayer.delegate = self
        youTubeVideoPlayerActivityIndicator.startAnimating()
        youTubeVideoPlayer.load(withVideoId: viewModel.youtubeVideoId, playerVars: youtubePlayerParameters)
        youTubeVideoPlayer.isHidden = false
        youTubeVideoPlayerLoadingView.isHidden = false
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeButtonTapped()
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
            
            self?.youTubeVideoPlayer.playVideo()
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
