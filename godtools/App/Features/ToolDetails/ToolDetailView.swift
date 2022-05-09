//
//  ToolDetailView.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import youtube_ios_player_helper

class ToolDetailView: UIViewController {
    
    private let viewModel: ToolDetailViewModelType
    
    private var learnToShareToolButtonStartingTop: CGFloat = 0
    private var didLayoutSubviews: Bool = false
    
    //topMediaView
    @IBOutlet weak private var topMediaView: UIView!
    @IBOutlet weak private var animationView: AnimatedView!
    @IBOutlet weak private var youTubePlayerContentView: UIView!
    @IBOutlet weak private var youTubePlayerView: YTPlayerView!
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
    @IBOutlet weak private var translationDownloadProgressView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var totalViewsLabel: UILabel!
    @IBOutlet weak private var openToolButton: UIButton!
    @IBOutlet weak private var unfavoriteButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var learnToShareToolButton: UIButton!
    
    //constraints
    @IBOutlet weak private var detailsLabelsViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var aboutDetailsTextViewLeading: NSLayoutConstraint!
    @IBOutlet weak private var languageDetailsTextViewLeading: NSLayoutConstraint!
    @IBOutlet weak private var translationDownloadProgressWidth: NSLayoutConstraint!
    @IBOutlet weak private var learnToShareToolButtonTop: NSLayoutConstraint!
                
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
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
                            
        addDefaultNavBackItem()
        
        openToolButton.addTarget(self, action: #selector(handleOpenTool(button:)), for: .touchUpInside)
        unfavoriteButton.addTarget(self, action: #selector(handleUnfavorite(button:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(handleFavorite(button:)), for: .touchUpInside)
        learnToShareToolButton.addTarget(self, action: #selector(handleLearnToShareTool(button:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            setLearnToShareToolButton(hidden: true, animated: false)
            
            viewModel.aboutDetails.addObserver(self) { [weak self] (aboutDetails: String) in
                self?.reloadDetailsTextViews()
            }
            
            viewModel.languageDetails.addObserver(self) { [weak self] (aboutDetails: String) in
                self?.reloadDetailsTextViews()
            }
            
            viewModel.hidesLearnToShareToolButton.addObserver(self) { [weak self] (hidesLearnToShareToolButton: Bool) in
                self?.setLearnToShareToolButton(hidden: hidesLearnToShareToolButton, animated: true)
            }
        }
    }
    
    private func setupLayout() {
        
        learnToShareToolButtonStartingTop = learnToShareToolButtonTop.constant
        
        // youTubeLoadingView
        youTubeLoadingView.backgroundColor = topMediaView.backgroundColor
        
        // detailsShadow
        detailsShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsShadow.layer.shadowColor = UIColor.black.cgColor
        detailsShadow.layer.shadowRadius = 5
        detailsShadow.layer.shadowOpacity = 0.3
        
        // translation progress
        setTranslationProgress(progress: 0, animated: false)
        
        // favorite and unfavorite buttons
        let buttonCornerRadius: CGFloat = 8
        openToolButton.layer.cornerRadius = buttonCornerRadius
        unfavoriteButton.layer.cornerRadius = buttonCornerRadius
        favoriteButton.layer.cornerRadius = buttonCornerRadius
        
        favoriteButton.layer.borderWidth = 1
        favoriteButton.layer.borderColor = favoriteButton.titleColor(for: .normal)?.cgColor
        
        unfavoriteButton.layer.borderWidth = 1
        unfavoriteButton.layer.borderColor = unfavoriteButton.titleColor(for: .normal)?.cgColor
        
        //learnToShareToolButton
        learnToShareToolButton.layer.cornerRadius = buttonCornerRadius
        
        // detailsView
        detailsView.backgroundColor = bottomView.backgroundColor
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.banner.addObserver(self) { [weak self] (value: ToolDetailBanner) in
            
            self?.animationView.stop()
            self?.animationView.isHidden = true
            self?.bannerImageView.image = nil
            self?.bannerImageView.isHidden = true
            self?.youTubePlayerView.stopVideo()
            self?.youTubePlayerContentView.isHidden = true
            
            switch value {
            case .animation(let viewModel):
                self?.animationView.isHidden = false
                self?.animationView.configure(viewModel: viewModel)
            case .image(let image):
                self?.bannerImageView.isHidden = false
                self?.setTopBannerImage(image: image)
            case .youtube(let videoId, let playerParameters):
                self?.youTubePlayerContentView.isHidden = false
                self?.loadYoutubePlayerVideo(videoId: videoId, playerParameters: playerParameters)
            case .empty:
                break
            }
        }
        
        viewModel.translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            self?.setTranslationProgress(progress: progress, animated: true)
        }
        
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
        
        viewModel.hidesUnfavoriteButton.addObserver(self) { [weak self] (isHidden: Bool) in
            self?.unfavoriteButton.isHidden = isHidden
        }
        
        viewModel.favoriteTitle.addObserver(self) { [weak self] (title: String) in
            self?.favoriteButton.setTitle(title, for: .normal)
        }
        
        viewModel.hidesFavoriteButton.addObserver(self) { [weak self] (isHidden: Bool) in
            self?.favoriteButton.isHidden = isHidden
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
    
    @objc func handleLearnToShareTool(button: UIButton) {
        viewModel.learnToShareToolTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        youTubePlayerView.playerState { [weak self] (state: YTPlayerState, error: Error?) in
            if state == .playing {
                self?.youTubePlayerView.pauseVideo()
            }
        }
    }
    
    private func setTopBannerImage(image: UIImage?) {
        
        let previousBannerImage: UIImage? = bannerImageView.image
        
        bannerImageView.image = image
        
        if previousBannerImage == nil {
            bannerImageView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.bannerImageView.alpha = 1
            }, completion: nil)
        }
    }
    
    private func setLearnToShareToolButton(hidden: Bool, animated: Bool) {
        
        let alpha: CGFloat = hidden ? 0 : 1
        
        if hidden {
            learnToShareToolButtonTop.constant = learnToShareToolButton.frame.size.height * -1
        }
        else {
            learnToShareToolButtonTop.constant = learnToShareToolButtonStartingTop
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                //animations
                self.learnToShareToolButton.alpha = alpha
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            learnToShareToolButton.alpha = alpha
            view.layoutIfNeeded()
        }
    }
     
    private func loadYoutubePlayerVideo(videoId: String, playerParameters: [String: Any]?) {
        youTubeActivityIndicator.startAnimating()
        youTubePlayerView.delegate = self
        youTubePlayerView.load(withVideoId: videoId, playerVars: playerParameters)
    }
    
    private func recueVideo() {
        
        guard let videoId = viewModel.banner.value.getYoutubeVideoId() else {
            return
        }
        
        youTubePlayerView.cueVideo(byId: videoId, startSeconds: 0.0)
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
    
    private func setTranslationProgress(progress: Double, animated: Bool) {
        
        UIView.setProgress(
            progress: progress,
            progressView: translationDownloadProgressView,
            progressViewWidth: translationDownloadProgressWidth,
            maxProgressViewWidth: view.frame.size.width,
            layoutView: contentView,
            animated: animated
        )
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

//MARK: -- YTPlayerViewDelegate

extension ToolDetailView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        print("\n ToolDetailView player view did become ready")
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.youTubeLoadingView.alpha = 0
        }) { [weak self] (finished: Bool) in
            self?.youTubeLoadingView.isHidden = true
            self?.youTubeLoadingView.alpha = 1
            self?.youTubeActivityIndicator.stopAnimating()
        }
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
        
        if state == .ended {
            
            switch viewModel.banner.value {
            case .youtube(let videoId, let playerParameters):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.loadYoutubePlayerVideo(videoId: videoId, playerParameters: playerParameters)
                }
            default:
                break
            }
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        
        print("\n ToolDetailView playerView didChangeTo quality")
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
        print("\n ToolDetailView playerView receivedError error")
        print("  error: \(error)")
    }
}
