//
//  TutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

protocol TutorialCellDelegate: class {
    func tutorialCellVideoPlayer(cell: TutorialCell, didChangeTo state: WKYTPlayerState)
}

class TutorialCell: UICollectionViewCell {
    
    static let nibName: String = "TutorialCell"
    static let reuseIdentifier: String = "TutorialCellReuseIdentifier"
    
    private weak var delegate: TutorialCellDelegate?
    private weak var tutorialCellViewModel: TutorialCellViewModel?
    private var youtubeVideoId: String?
    
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
        mainImageView.image = nil
        for subview in customViewContainer.subviews {
            subview.removeFromSuperview()
        }
        youTubeVideoPlayerLoadingView.alpha = 1
        
        delegate = nil
    }
    
    func configure(viewModel: TutorialCellViewModel, delegate: TutorialCellDelegate?) {
        self.delegate = delegate
        self.tutorialCellViewModel = viewModel
        self.youtubeVideoId = viewModel.youTubeVideoId
        
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
            youTubeVideoPlayer.load(withVideoId: viewModel.youTubeVideoId, playerVars: ["playsinline": 0])
        }
        
        if !viewModel.hidesCustomView {
            customViewContainer.addSubview(viewModel.customView)
            viewModel.customView.constrainEdgesToSuperview()
        }
    }
    
    func stopVideo() {
        youTubeVideoPlayer.stopVideo()
    }
    
    func recueVideo() {
        youTubeVideoPlayer.cueVideo(byId: youtubeVideoId!, startSeconds: 0.0, suggestedQuality: WKYTPlaybackQuality.auto)
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
        print(state.rawValue)
        delegate?.tutorialCellVideoPlayer(cell: self, didChangeTo: state)
        
        if state == WKYTPlayerState.ended {
           recueVideo()
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
    
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        print("\n TutorialCell: youTubeVideoPlayer receivedError")
        print("  error: \(error)")
    }
}
