//
//  TutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import Lottie

protocol TutorialCellDelegate: AnyObject {
    func tutorialCellVideoPlayer(cell: TutorialCell, didChangeTo state: YTPlayerState)
}

class TutorialCell: UICollectionViewCell {
    
    static let nibName: String = "TutorialCell"
    static let reuseIdentifier: String = "TutorialCellReuseIdentifier"
    
    private weak var delegate: TutorialCellDelegate?
    private var viewModel: TutorialCellViewModelType?
    private var mainImage: UIImage?
    private var mainImageView: UIImageView?
    private var customView: UIView?
    private var initialTopSpaceForMessageLabel: CGFloat = 16

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var dynamicMediaView: UIView!
    @IBOutlet weak private var youTubeVideoPlayer: YTPlayerView!
    @IBOutlet weak private var youTubeVideoPlayerLoadingView: UIView!
    @IBOutlet weak private var youTubeVideoPlayerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var animationView: AnimationView!
    
    @IBOutlet weak private var messageLabelTop: NSLayoutConstraint!
    @IBOutlet weak private var dynamicMediaHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        initialTopSpaceForMessageLabel = messageLabelTop.constant
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        titleLabel.text = nil
        setMessageLabelHidden(hidden: false)
        mainImageView?.removeFromSuperview()
        mainImage = nil
        mainImageView = nil
        stopVideo()
        youTubeVideoPlayerLoadingView.alpha = 1
        animationView.stop()
        animationView.animation = nil
        customView?.removeFromSuperview()
        customView = nil
        viewModel = nil
        delegate = nil
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()

        renderMainImageIfNeeded()
        renderCustomViewIfNeeded()
        recalculateDynamicMediaHeight()
    }
    
    var youtubePlayerParameters: [String : Any]? {
        let playsInFullScreen = 0
        
        return [
            "playsinline": playsInFullScreen
        ]
    }
    
    func configure(viewModel: TutorialCellViewModelType, delegate: TutorialCellDelegate?) {
        
        self.delegate = delegate
        self.viewModel = viewModel
        
        // titleLabel
        titleLabel.text = viewModel.title
        
        // messageLabel
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
        setMessageLabelHidden(hidden: viewModel.message.isEmpty)
        
        // mainImage
        if let mainImageName = viewModel.mainImageName, !mainImageName.isEmpty, let mainImage = UIImage(named: mainImageName) {
            self.mainImage = mainImage
            renderMainImage(mainImage: mainImage, mainImageView: nil)
        }
        else {
            mainImageView?.removeFromSuperview()
            mainImageView = nil
            mainImage = nil
        }
        
        // youTubeVideo
        let hidesYouTubeVideoPlayer: Bool
        if let youTubVideoId = viewModel.youTubeVideoId, !youTubVideoId.isEmpty {
            hidesYouTubeVideoPlayer = false
            youTubeVideoPlayerActivityIndicator.startAnimating()
            youTubeVideoPlayer.delegate = self
            youTubeVideoPlayer.load(withVideoId: youTubVideoId, playerVars: youtubePlayerParameters)
        }
        else {
            hidesYouTubeVideoPlayer = true
            youTubeVideoPlayer.stopVideo()
            youTubeVideoPlayer.delegate = nil
            youTubeVideoPlayerActivityIndicator.stopAnimating()
        }

        youTubeVideoPlayer.isHidden = hidesYouTubeVideoPlayer
        youTubeVideoPlayerLoadingView.isHidden = hidesYouTubeVideoPlayer
        
        // animation
        if let animationName = viewModel.animationName, !animationName.isEmpty {
            let animation = Animation.named(animationName)
            animationView.animation = animation
            animationView.loopMode = .loop
            animationView.play()
            animationView.isHidden = false
        }
        else {
            animationView.stop()
            animationView.isHidden = true
        }
        
        // customView
        if let customView = viewModel.customView {
            self.customView = customView
            dynamicMediaView.addSubview(customView)
        }
        else {
            customView?.removeFromSuperview()
            self.customView = nil
        }
    }
    
    private func setMessageLabelHidden(hidden: Bool) {

        messageLabel.isHidden = hidden
        messageLabelTop.constant = hidden ? 0 : initialTopSpaceForMessageLabel
        contentView.layoutIfNeeded()
    }

    private func renderMainImageIfNeeded() {

        if let mainImage = self.mainImage {
            renderMainImage(mainImage: mainImage, mainImageView: mainImageView)
        }
    }
    
    private func renderMainImage(mainImage: UIImage, mainImageView: UIImageView?) {

        let imageView: UIImageView = mainImageView ?? UIImageView()
        
        self.mainImage = mainImage
        self.mainImageView = imageView
        
        imageView.image = mainImage
        
        renderMedia(
            view: imageView,
            originalViewSize: mainImage.size
        )
    }
    
    private func renderCustomViewIfNeeded() {
        
        if let customView = self.customView {
            renderCustomView(customView: customView)
        }
    }
    
    private func renderCustomView(customView: UIView) {
        
        self.customView = customView
        
        renderMedia(
            view: customView,
            originalViewSize: customView.frame.size
        )
    }
    
    private func renderMedia(view: UIView, originalViewSize: CGSize) {
        
        contentView.layoutIfNeeded()
        
        let parentView: UIView = dynamicMediaView
        let parentWidth: CGFloat = parentView.bounds.size.width
        let scaleOfMaxWidthToParentWidth: CGFloat = 0.9
        let maxAllowedWidth: CGFloat = parentWidth * scaleOfMaxWidthToParentWidth

        let scale: CGFloat = maxAllowedWidth / originalViewSize.width

        let scaledViewSize: CGSize = CGSize(
            width: floor(maxAllowedWidth),
            height: floor(originalViewSize.height * scale)
        )
        
        let viewFrame: CGRect = CGRect(
            x: parentWidth / 2 - scaledViewSize.width / 2,
            y: 0,
            width: scaledViewSize.width,
            height: scaledViewSize.height
        )
        
        view.frame = viewFrame
        
        if view.superview == nil {
            parentView.addSubview(view)
        }
        
        if let imageView = view as? UIImageView {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
    }
    
    private func recalculateDynamicMediaHeight() {
        
        contentView.layoutIfNeeded()
        
        var maxSubviewHeight: CGFloat = 20
        
        for subview in dynamicMediaView.subviews {
            
            let subviewIsHidden: Bool = subview.isHidden || subview.alpha == 0
            
            if !subviewIsHidden && subview.frame.size.height > maxSubviewHeight {
                maxSubviewHeight = subview.frame.size.height
            }
        }
        
        dynamicMediaHeight.constant = maxSubviewHeight
        contentView.layoutIfNeeded()
    }
    
    func stopVideo() {
        youTubeVideoPlayer.stopVideo()
    }
    
    private func recueVideo() {
        guard let youtubeVideoId = viewModel?.youTubeVideoId else { return }
        
        youTubeVideoPlayer.cueVideo(byId: youtubeVideoId, startSeconds: 0.0)
    }
}

extension TutorialCell: YTPlayerViewDelegate {
    
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
        delegate?.tutorialCellVideoPlayer(cell: self, didChangeTo: state)
        
        if state == YTPlayerState.ended {
           recueVideo()
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
    
    }
    
    func playerView(_ playerView: YTPlayerError, receivedError error: YTPlayerError) {
        print("\n TutorialCell: youTubeVideoPlayer receivedError")
        print("  error: \(error)")
    }
}
