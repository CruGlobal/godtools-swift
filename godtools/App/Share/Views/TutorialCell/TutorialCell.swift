//
//  TutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import YouTubeiOSPlayerHelper

class TutorialCell: UICollectionViewCell {
    
    static let nibName: String = "TutorialCell"
    static let reuseIdentifier: String = "TutorialCellReuseIdentifier"
    
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
    @IBOutlet weak private var animatedView: AnimatedView!
    
    @IBOutlet weak private var messageLabelTop: NSLayoutConstraint!
    @IBOutlet weak private var dynamicMediaHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupLayout()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        titleLabel.text = nil
        setMessageLabelHidden(hidden: false)
        resetAssetContent()
        viewModel = nil
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()

        renderMainImageIfNeeded()
        renderCustomViewIfNeeded()
        recalculateDynamicMediaHeight()
    }
    
    private func setupLayout() {
        
        initialTopSpaceForMessageLabel = messageLabelTop.constant
        
        resetAssetContent()
    }
    
    func configure(viewModel: TutorialCellViewModelType) {
        
        self.viewModel = viewModel
        
        // titleLabel
        titleLabel.text = viewModel.title
        
        // messageLabel
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
        setMessageLabelHidden(hidden: viewModel.message.isEmpty)
        
        switch viewModel.assetContent {
            
        case .animation(let animatedViewModel):
            
            animatedView.configure(viewModel: animatedViewModel)
            animatedView.isHidden = false
            
        case .customView(let customView):
            
            self.customView = customView
            dynamicMediaView.addSubview(customView)
        
        case .image(let image):
            
            self.mainImage = image
            renderMainImage(mainImage: image, mainImageView: nil)
            
        case .video(let youTubeVideoId, let youTubeVideoParameters):
            
            youTubeVideoPlayerActivityIndicator.startAnimating()
            youTubeVideoPlayer.delegate = self
            youTubeVideoPlayer.load(withVideoId: youTubeVideoId, playerVars: youTubeVideoParameters)
            youTubeVideoPlayer.isHidden = false
            youTubeVideoPlayerLoadingView.isHidden = false
            
        case .none:
            break
        }
    }
    
    private func resetAssetContent() {
        resetMainImage()
        resetAnimation()
        resetVideo()
        resetCustomView()
    }
    
    private func resetMainImage() {
        mainImageView?.removeFromSuperview()
        mainImage = nil
        mainImageView = nil
    }
    
    private func resetAnimation() {
        animatedView.destroyAnimation()
        animatedView.isHidden = true
    }
    
    private func resetVideo() {
        youTubeVideoPlayer.stopVideo()
        youTubeVideoPlayer.isHidden = true
        youTubeVideoPlayer.delegate = nil
        youTubeVideoPlayerLoadingView.isHidden = true
        youTubeVideoPlayerActivityIndicator.stopAnimating()
        youTubeVideoPlayerLoadingView.alpha = 1
    }
    
    private func resetCustomView() {
        customView?.removeFromSuperview()
        customView = nil
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
        
        guard let youtubeVideoId = viewModel?.getYouTubeVideoId() else {
            return
        }
        
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
        
        if state == .playing {
            viewModel?.tutorialVideoPlayTapped()
        } else if state == .ended {
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
