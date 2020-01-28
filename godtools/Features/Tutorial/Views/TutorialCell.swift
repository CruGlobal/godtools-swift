//
//  TutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class TutorialCell: UICollectionViewCell {
    
    static let nibName: String = "TutorialCell"
    static let reuseIdentifier: String = "TutorialCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var customViewContainer: UIView!
    @IBOutlet weak private var mainImageView: UIImageView!
    @IBOutlet weak private var youTubeVideoPlayer: WKYTPlayerView!
    @IBOutlet weak private var youTubeVideoPlayerLoadingView: UIView!
    @IBOutlet weak private var youTubeVideoPlayerActivityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopVideo()
    }
    
    func configure(viewModel: TutorialCellViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
        mainImageView.isHidden = viewModel.hidesMainImage
        youTubeVideoPlayer.isHidden = viewModel.hidesYouTubeVideoPlayer
        youTubeVideoPlayerLoadingView.isHidden = viewModel.hidesYouTubeVideoPlayer
        customViewContainer.isHidden = viewModel.hidesCustomView
        
        if !viewModel.hidesMainImage {
            mainImageView.image = viewModel.mainImage
        }
        
        if !viewModel.hidesYouTubeVideoPlayer {
            youTubeVideoPlayerActivityIndicator.startAnimating()
            youTubeVideoPlayer.delegate = self
            youTubeVideoPlayer.load(withVideoId: viewModel.youTubeVideoId, playerVars: ["playsinline": 1])
        }
        
        if !viewModel.hidesCustomView {
            customViewContainer.addSubview(viewModel.customView)
            viewModel.customView.constrainEdgesToSuperview()
        }
    }
    
    func stopVideo() {
        youTubeVideoPlayer.stopVideo()
    }
}

extension TutorialCell: WKYTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.youTubeVideoPlayerLoadingView.alpha = 0
        }) { [weak self] (finished: Bool) in
            self?.youTubeVideoPlayerLoadingView.isHidden = true
            self?.youTubeVideoPlayerLoadingView.alpha = 1
            self?.youTubeVideoPlayerActivityIndicator.stopAnimating()
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {

    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
    
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        print("\n TutorialCell: youTubeVideoPlayer receivedError")
        print("  error: \(error)")
    }
}
