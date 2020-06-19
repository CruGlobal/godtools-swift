//
//  ToolDetailView.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import YoutubePlayer_in_WKWebView

class ToolDetailView: UIViewController {
    
    private let viewModel: ToolDetailViewModelType
    
    private var didLayoutSubviews: Bool = false
    
    //topMediaView
    @IBOutlet weak private var topMediaView: UIView!
    @IBOutlet weak private var youTubePlayerContentView: UIView!
    @IBOutlet weak private var youTubePlayerView: WKYTPlayerView!
    @IBOutlet weak private var youTubeLoadingView: UIView!
    @IBOutlet weak private var youTubeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    //bottomView
    @IBOutlet weak private var bottomView: UIView!
    //scrollView
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var detailsView: UIView!
    @IBOutlet weak private var detailsLabelsView: UIView!
    @IBOutlet weak private var aboutDetailsTextView: UITextView!
    @IBOutlet weak private var languageDetailsTextView: UITextView!
    @IBOutlet weak private var detailsShadow: UIView!
    @IBOutlet weak private var clipTopDetailsShadow: UIView!
    @IBOutlet weak private var detailsControl: GTSegmentedControl!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var totalViewsLabel: UILabel!
    @IBOutlet weak private var openToolButton: UIButton!
    @IBOutlet weak private var unfavoriteButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    //constraints
    @IBOutlet weak private var detailsLabelsViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var aboutDetailsTextViewLeading: NSLayoutConstraint!
    @IBOutlet weak private var languageDetailsTextViewLeading: NSLayoutConstraint!
                
    required init(viewModel: ToolDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ToolDetailView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        youTubePlayerView.stopVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBinding()
                            
        addDefaultNavBackItem()
        
        openToolButton.addTarget(self, action: #selector(handleOpenTool(button:)), for: .touchUpInside)
        unfavoriteButton.addTarget(self, action: #selector(handleUnfavorite(button:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(handleFavorite(button:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            viewModel.aboutDetails.addObserver(self) { [weak self] (aboutDetails: String) in
                self?.reloadDetailsTextViews()
            }
            
            viewModel.languageDetails.addObserver(self) { [weak self] (aboutDetails: String) in
                self?.reloadDetailsTextViews()
            }
        }
    }
    
    private func setupLayout() {
        
        // youTubeLoadingView
        youTubeLoadingView.backgroundColor = topMediaView.backgroundColor
        
        // detailsShadow
        detailsShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsShadow.layer.shadowColor = UIColor.black.cgColor
        detailsShadow.layer.shadowRadius = 5
        detailsShadow.layer.shadowOpacity = 0.3
        
        // favorite and unfavorite buttons
        let buttonCornerRadius: CGFloat = 8
        openToolButton.layer.cornerRadius = buttonCornerRadius
        unfavoriteButton.layer.cornerRadius = buttonCornerRadius
        favoriteButton.layer.cornerRadius = buttonCornerRadius
        
        favoriteButton.layer.borderWidth = 1
        favoriteButton.layer.borderColor = favoriteButton.titleColor(for: .normal)?.cgColor
        
        unfavoriteButton.layer.borderWidth = 1
        unfavoriteButton.layer.borderColor = unfavoriteButton.titleColor(for: .normal)?.cgColor
        
        // detailsView
        detailsView.backgroundColor = bottomView.backgroundColor
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.topToolDetailMedia.addObserver(self) { [weak self] (toolDetailMedia: ToolDetailMedia?) in
                      
            if let newBannerImage = toolDetailMedia?.bannerImage {
                self?.setTopBannerImage(image: newBannerImage)
            }
            else if let youtubePlayerId = toolDetailMedia?.youtubePlayerId, !youtubePlayerId.isEmpty {
                self?.loadYoutubePlayerVideo(videoId: youtubePlayerId)
            }
        }
        
        bannerImageView.isHidden = viewModel.hidesBannerImage
        youTubePlayerContentView.isHidden = viewModel.hidesYoutubePlayer
        
        viewModel.name.addObserver(self) { [weak self] (name: String) in
            self?.nameLabel.text = name
        }
        
        viewModel.totalViews.addObserver(self) { [weak self] (totalViews: String) in
            self?.totalViewsLabel.text = totalViews
        }
        
        viewModel.openToolTitle.addObserver(self) { [weak self] (title: String) in
            self?.openToolButton.setTitle(title, for: .normal)
        }
        
        viewModel.unfavoriteTitle.addObserver(self) { [weak self] (title: String) in
            self?.unfavoriteButton.setTitle(title, for: .normal)
        }
        
        viewModel.favoriteTitle.addObserver(self) { [weak self] (title: String) in
            self?.favoriteButton.setTitle(title, for: .normal)
        }
        
        viewModel.toolDetailsControls.addObserver(self) { [weak self] (detailsSegments: [ToolDetailControl]) in
            
            if !detailsSegments.isEmpty {
                
                guard let toolDetailView = self else {
                    return
                }
                
                var detailsControlLayout = GTSegmentedControl.LayoutConfig.defaultLayout
                detailsControlLayout.spacingBetweenSegments = 54
                self?.detailsControl.configure(
                    segments: detailsSegments,
                    delegate: toolDetailView,
                    layout: detailsControlLayout
                )
            }
        }
        
        viewModel.selectedDetailControl.addObserver(self) { [weak self] (detailControl: ToolDetailControl?) in
            
            guard let toolDetailView = self else {
                return
            }
                        
            switch detailControl?.controlId ?? .about {
            case .about:
                toolDetailView.aboutDetailsTextViewLeading.constant = 0
                toolDetailView.languageDetailsTextViewLeading.constant = toolDetailView.view.bounds.size.width
            case .languages:
                toolDetailView.aboutDetailsTextViewLeading.constant = toolDetailView.view.bounds.size.width * -1
                toolDetailView.languageDetailsTextViewLeading.constant = 0
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                toolDetailView.detailsView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func handleOpenTool(button: UIButton) {
        viewModel.openToolTapped()
    }
    
    @objc func handleUnfavorite(button: UIButton) {
        viewModel.unfavoriteTapped()
    }
    
    @objc func handleFavorite(button: UIButton) {
        viewModel.favoriteTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        youTubePlayerView.getPlayerState { [weak self] (state: WKYTPlayerState, error: Error?) in
            if state == .playing {
                self?.youTubePlayerView.pauseVideo()
            }
        }
    }
    
    private func setTopBannerImage(image: UIImage) {
        
        let previousBannerImage: UIImage? = bannerImageView.image
        
        bannerImageView.image = image
        
        if previousBannerImage == nil {
            bannerImageView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.bannerImageView.alpha = 1
            }, completion: nil)
        }
    }
     
    private func loadYoutubePlayerVideo(videoId: String) {
        youTubeActivityIndicator.startAnimating()
        youTubePlayerView.delegate = self
        youTubePlayerView.load(withVideoId: videoId, playerVars: ["playsinline": 1])
    }

    private func reloadDetailsTextViews() {
        
        let detailsTextViews: [UITextView] = [aboutDetailsTextView, languageDetailsTextView]
        
        for textView in detailsTextViews {
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.dataDetectorTypes = .link
            textView.delegate = self
        }
        
        let aboutDetailsText: String = viewModel.aboutDetails.value
        let languageDetailsText: String = viewModel.languageDetails.value
        let textAlignment: NSTextAlignment = .center
                
        aboutDetailsTextView.text = aboutDetailsText
        languageDetailsTextView.text = languageDetailsText
        
        var maxDetailLabelHeight: CGFloat = 0
        
        for textView in detailsTextViews {
            textView.textAlignment = textAlignment
            textView.setLineSpacing(lineSpacing: 3)
            textView.layoutIfNeeded()
            textView.superview?.layoutIfNeeded()
            if textView.frame.size.height > maxDetailLabelHeight {
                maxDetailLabelHeight = textView.frame.size.height
            }
        }
        
        detailsLabelsViewHeight.constant = maxDetailLabelHeight
        view.layoutIfNeeded()
    }
}

// MARK: - UITextViewDelegate

extension ToolDetailView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
                
        viewModel.urlTapped(url: URL)
        
        return false
    }
}

// MARK: - GTSegmentedControlDelegate

extension ToolDetailView: GTSegmentedControlDelegate {
    
    func segmentedControl(segmentedControl: GTSegmentedControl, didSelect segment: GTSegmentType, at index: Int) {
        
        if let detailControl = segment as? ToolDetailControl {
            viewModel.detailControlTapped(detailControl: detailControl)
        }
    }
}

extension ToolDetailView: WKYTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.youTubeLoadingView.alpha = 0
        }) { [weak self] (finished: Bool) in
            self?.youTubeLoadingView.isHidden = true
            self?.youTubeLoadingView.alpha = 1
            self?.youTubeActivityIndicator.stopAnimating()
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        
        print("\n ToolDetailView playerView didChangeTo state")
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
        
        print("\n ToolDetailView playerView didChangeTo quality")
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        
        print("\n ToolDetailView playerView receivedError error")
        print("  error: \(error)")
    }
}
