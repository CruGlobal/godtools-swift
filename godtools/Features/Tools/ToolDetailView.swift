//
//  ToolDetailView.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//


import UIKit
import TTTAttributedLabel
import YoutubePlayer_in_WKWebView

class ToolDetailView: UIViewController {
    
    enum SegmentedControlId: String {
        case about = "about"
        case language = "language"
    }
    
    private let viewModel: ToolDetailViewModelType
        
    private var detailsSegments: [GTSegment] = Array()
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var topView: UIView!
    @IBOutlet weak private var bottomView: UIView!
    @IBOutlet weak private var youTubePlayerView: WKYTPlayerView!
    @IBOutlet weak private var youTubeLoadingView: UIView!
    @IBOutlet weak private var youTubeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var titleLabel: GTLabel!
    @IBOutlet weak private var totalViewsLabel: GTLabel!
    @IBOutlet weak private var openToolButton: GTButton!
    @IBOutlet weak private var mainButton: GTButton!
    @IBOutlet weak private var detailsControl: GTSegmentedControl!
    @IBOutlet weak private var detailsView: UIView!
    @IBOutlet weak private var detailsLabelsView: UIView!
    @IBOutlet weak private var aboutDetailsTextView: UITextView!
    @IBOutlet weak private var languageDetailsTextView: UITextView!
    @IBOutlet weak private var detailsShadow: UIView!
    @IBOutlet weak private var downloadProgressView: GTProgressView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    
    @IBOutlet weak private var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak private var mainButtonTopToTotalViewsLabel: NSLayoutConstraint!
    @IBOutlet weak private var mainButtonTopToOpenToolButton: NSLayoutConstraint!
    @IBOutlet weak private var detailsLabelsViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var detailsLabelsViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var aboutDetailsTextViewLeading: NSLayoutConstraint!
    @IBOutlet weak private var languageDetailsTextViewLeading: NSLayoutConstraint!
    
    let toolsManager = ToolsManager.shared
            
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
        
        openToolButton.designAsOpenToolButton()
                    
        displayData()
        registerForDownloadProgressNotifications()
        setTopHeight()
        
        addDefaultNavBackItem()
        
        openToolButton.addTarget(
            self,
            action: #selector(handleOpenTool(button:)),
            for: .touchUpInside
        )
    }
    
    private func setupLayout() {
        
        topView.backgroundColor = view.backgroundColor
        bottomView.backgroundColor = detailsView.backgroundColor
        
        youTubePlayerView.isHidden = true
        
        // detailsShadow
        detailsShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsShadow.layer.shadowColor = UIColor.black.cgColor
        detailsShadow.layer.shadowRadius = 5
        detailsShadow.layer.shadowOpacity = 0.3
    }
    
    private func setupBinding() {
        
        title = viewModel.navTitle
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            if viewModel.hidesOpenToolButton {
                mainButtonTopToTotalViewsLabel.isActive = true
                mainButtonTopToOpenToolButton.isActive = false
                openToolButton.isHidden = true
            }
        }
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
    
    func setTopHeight() {
        let barHeight = navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let topBar = barHeight + statusBarHeight
        topLayoutConstraint.constant = topBar
        view.layoutIfNeeded()
    }

    // MARK: Present data
    
    fileprivate func displayData() {
        
        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
        let resource: DownloadedResource = viewModel.resource
        
        let aboutVideoYouTubePlayerId: String = resource.aboutOverviewVideoYouTube ?? ""
        if aboutVideoYouTubePlayerId.isEmpty {
            youTubePlayerView.isHidden = true
            youTubeLoadingView.isHidden = true
            bannerImageView.isHidden = false
        }
        else {
            youTubePlayerView.isHidden = false
            youTubeLoadingView.isHidden = false
            bannerImageView.isHidden = true
            youTubeActivityIndicator.startAnimating()
            youTubePlayerView.delegate = self
            youTubePlayerView.load(withVideoId: aboutVideoYouTubePlayerId, playerVars: ["playsinline": 1])
        }
        
        // if tool is available in primary language, attempt to retrieve string based on that lanague else default to device language
        let localizedTotalViews = resource.isAvailableInLanguage(primaryLanguage) ? "total_views".localized(for: primaryLanguage?.code) ?? "total_views".localized : "total_views".localized
        totalViewsLabel.text = String.localizedStringWithFormat(localizedTotalViews, resource.totalViews)
        
        let localizedTotalLanguages =  resource.isAvailableInLanguage(primaryLanguage) ? "total_languages".localized(for: primaryLanguage?.code) ?? "total_languages".localized : "total_languages".localized
        
        titleLabel.text = resource.localizedName(language: primaryLanguage)
                                
        displayButton()
        bannerImageView.image = BannerManager().loadFor(remoteId: resource.aboutBannerRemoteId)
        
        let textAlignment: NSTextAlignment = (resource.isAvailableInLanguage(primaryLanguage) && primaryLanguage?.isRightToLeft() ?? false) ? .right : .natural
                
        titleLabel.textAlignment = textAlignment
        totalViewsLabel.textAlignment = textAlignment
        
        setupDetailsLabels(
            aboutDetails: viewModel.aboutDetails,
            languageDetails: viewModel.languageDetails,
            textAlignment: textAlignment
        )
        
        let aboutSegment = GTSegment(
            id: SegmentedControlId.about.rawValue,
            title: String.localizedStringWithFormat(resource.isAvailableInLanguage(primaryLanguage) ? "about".localized(for: primaryLanguage?.code) ?? "about".localized : "about".localized, resource.totalViews).capitalized
        )
        
        let languageSement = GTSegment(
            id: SegmentedControlId.language.rawValue,
            title: String.localizedStringWithFormat(localizedTotalLanguages.localized, resource.numberOfAvailableLanguages()).capitalized
        )
        
        detailsSegments = [aboutSegment, languageSement]
        var detailsControlLayout = GTSegmentedControl.LayoutConfig.defaultLayout
        detailsControlLayout.spacingBetweenSegments = 54
        detailsControl.configure(segments: detailsSegments, delegate: self, layout: detailsControlLayout)
    }

    private func setupDetailsLabels(aboutDetails: String, languageDetails: String, textAlignment: NSTextAlignment) {
        
        let detailsTextViews: [UITextView] = [aboutDetailsTextView, languageDetailsTextView]
        
        for textView in detailsTextViews {
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.dataDetectorTypes = .link
            textView.delegate = self
        }
        
        aboutDetailsTextView.text = aboutDetails
        languageDetailsTextView.text = languageDetails
        
        var maxDetailLabelHeight: CGFloat = 0
        
        for textView in detailsTextViews {
            textView.textAlignment = textAlignment
            textView.setLineSpacing(lineSpacing: 3)
            textView.layoutIfNeeded()
            if textView.frame.size.height > maxDetailLabelHeight {
                maxDetailLabelHeight = textView.frame.size.height
            }
        }
        
        detailsLabelsViewHeight.constant = maxDetailLabelHeight
        detailsView.layoutIfNeeded()
    }
    
    private func displayButton() {
        
        let resource: DownloadedResource = viewModel.resource
        
        if resource.numberOfAvailableLanguages() == 0 {
            mainButton.designAsUnavailableButton()
        } else if resource.shouldDownload {
            mainButton.designAsDeleteButton()
        } else {
            mainButton.designAsDownloadButton()
        }
    }
    
    private func registerForDownloadProgressNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(progressViewListenerShouldUpdate),
                                               name: .downloadProgressViewUpdateNotification,
                                               object: nil)
    }
    
    @objc private func progressViewListenerShouldUpdate(notification: NSNotification) {
        
        guard let resourceId = notification.userInfo![GTConstants.kDownloadProgressResourceIdKey] as? String else {
            return
        }
        
        let resource: DownloadedResource = viewModel.resource
        
        if resourceId != resource.remoteId {
            return
        }
        
        guard let progress = notification.userInfo![GTConstants.kDownloadProgressProgressKey] as? Progress else {
            return
        }
        
        OperationQueue.main.addOperation { [weak self] in
            
            self?.downloadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
            
            if progress.fractionCompleted == 1.0 {
                self?.returnToHome()
            }
        }
    }
    
    @objc func handleOpenTool(button: UIButton) {

        viewModel.openToolTapped()
    }
    
    @IBAction func mainButtonWasPressed(_ sender: Any) {
        
        // TODO: Navigate back to my tools through flow. ~Levi
        navigationController?.popViewController(animated: true)

        let resource: DownloadedResource = viewModel.resource
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
            
            if resource.shouldDownload {
                DownloadedResourceManager().delete(resource)
                self?.downloadProgressView.setProgress(0.0, animated: false)
                NotificationCenter.default.post(name: .reloadHomeListNotification, object: nil)
            } else {
                DownloadedResourceManager().download(resource)
            }
        }
        displayButton()
    }
    
    private func returnToHome() {
        let time = DispatchTime.now() + 0.55
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            // TODO: Navigate back to my tools through flow. ~Levi
            self?.navigationController?.popViewController(animated: true)
        }
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
        
        if let segmentId = SegmentedControlId(rawValue: segment.id) {
                    
            switch segmentId {
            case .about:
                aboutDetailsTextViewLeading.constant = 0
                languageDetailsTextViewLeading.constant = view.bounds.size.width
            case .language:
                aboutDetailsTextViewLeading.constant = view.bounds.size.width * -1
                languageDetailsTextViewLeading.constant = 0
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.detailsView.layoutIfNeeded()
            }, completion: nil)
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
        
        print("\n playerView didChangeTo state")
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
        
        print("\n playerView didChangeTo quality")
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        
        print("\n playerView receivedError error")
        print("  error: \(error)")
    }
}
