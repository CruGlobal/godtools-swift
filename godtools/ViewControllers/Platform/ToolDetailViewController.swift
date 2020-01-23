//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//


import UIKit
import TTTAttributedLabel
import YoutubePlayer_in_WKWebView

protocol ToolDetailViewControllerDelegate: class {
    func openToolTapped(toolDetail: ToolDetailViewController, resource: DownloadedResource)
}

class ToolDetailViewController: BaseViewController {
    
    enum SegmentedControlId: String {
        case about = "about"
        case language = "language"
    }
        
    private var detailsSegments: [GTSegment] = Array()
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var topView: UIView!
    @IBOutlet weak private var bottomView: UIView!
    @IBOutlet weak private var youTubePlayerView: WKYTPlayerView!
    @IBOutlet weak private var youTubeLoadingView: UIView!
    @IBOutlet weak private var youTubeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak private var openToolButton: GTButton!
    @IBOutlet weak var mainButton: GTButton!
    @IBOutlet weak private var detailsControl: GTSegmentedControl!
    @IBOutlet weak private var detailsView: UIView!
    @IBOutlet weak private var detailsLabelsView: UIView!
    @IBOutlet weak private var aboutDetailsLabel: TTTAttributedLabel!
    @IBOutlet weak private var languageDetailsLabel: TTTAttributedLabel!
    @IBOutlet weak private var detailsShadow: UIView!
    @IBOutlet weak var downloadProgressView: GTProgressView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTopToTotalViewsLabel: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTopToOpenToolButton: NSLayoutConstraint!
    @IBOutlet weak private var detailsLabelsViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var detailsLabelsViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var aboutDetailsLabelLeading: NSLayoutConstraint!
    @IBOutlet weak private var languageDetailsLabelLeading: NSLayoutConstraint!
    
    let toolsManager = ToolsManager.shared
    
    var resource: DownloadedResource?
    
    weak var delegate: ToolDetailViewControllerDelegate?
    
    deinit {
        youTubePlayerView.stopVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openToolButton.designAsOpenToolButton()
                    
        topView.backgroundColor = view.backgroundColor
        bottomView.backgroundColor = detailsView.backgroundColor
        
        youTubePlayerView.isHidden = true
        
        detailsShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsShadow.layer.shadowColor = UIColor.black.cgColor
        detailsShadow.layer.shadowRadius = 5
        detailsShadow.layer.shadowOpacity = 0.3
        
        self.displayData()
        self.hideScreenTitle()
        registerForDownloadProgressNotifications()
        setTopHeight()
        
        openToolButton.addTarget(self, action: #selector(handleOpenTool(button:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            didLayoutSubviews = true
            if !showsOpenToolButton {
                mainButtonTopToTotalViewsLabel.isActive = true
                mainButtonTopToOpenToolButton.isActive = false
                openToolButton.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
        let topBar = barHeight + statusBarHeight
        self.topLayoutConstraint.constant = topBar
        self.view.layoutIfNeeded()
    }

    // MARK: Present data
    
    fileprivate func displayData() {
        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
        guard let resource = resource else { return }
        
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
        self.totalViewsLabel.text = String.localizedStringWithFormat(localizedTotalViews, resource.totalViews)
        
        let localizedTotalLanguages =  resource.isAvailableInLanguage(primaryLanguage) ? "total_languages".localized(for: primaryLanguage?.code) ?? "total_languages".localized : "total_languages".localized
        
        self.titleLabel.text = resource.localizedName(language: primaryLanguage)
                
        let resourceTranslations = Array(Set(resource.translations))
        var translationStrings = [String]()
        
        let languageCode = primaryLanguage?.code ?? "en"
        let locale = resource.isAvailableInLanguage(primaryLanguage) ? Locale(identifier:  languageCode) : Locale.current
        for translation in resourceTranslations {
            guard translation.language != nil else {
                continue
            }
            guard let languageLocalName = translation.language?.localizedName(locale: locale) else {
                continue
            }
            translationStrings.append(languageLocalName)
        }
        
        self.displayButton()
        self.bannerImageView.image = BannerManager().loadFor(remoteId: resource.aboutBannerRemoteId)
        
        let textAlignment: NSTextAlignment = (resource.isAvailableInLanguage(primaryLanguage) && primaryLanguage?.isRightToLeft() ?? false) ? .right : .natural
                
        titleLabel.textAlignment = textAlignment
        totalViewsLabel.textAlignment = textAlignment
        
        setupDetailsLabels(
            aboutDetails: loadDescription(),
            languageDetails: translationStrings.sorted(by: { $0 < $1 }).joined(separator: ", "),
            textAlignment: textAlignment
        )
        
        let aboutSegment = GTSegment(
            id: SegmentedControlId.about.rawValue,
            title: String.localizedStringWithFormat(resource.isAvailableInLanguage(primaryLanguage) ? "about".localized(for: primaryLanguage?.code) ?? "about".localized : "about".localized, resource.totalViews)
        )
        
        let languageSement = GTSegment(
            id: SegmentedControlId.language.rawValue,
            title: String.localizedStringWithFormat(localizedTotalLanguages.localized, resource.numberOfAvailableLanguages())
        )
        
        detailsSegments = [aboutSegment, languageSement]
        detailsControl.configure(segments: detailsSegments, delegate: self)
    }
    
    private var showsOpenToolButton: Bool {
        return resource?.shouldDownload ?? false
    }
    
    private func setupDetailsLabels(aboutDetails: String, languageDetails: String, textAlignment: NSTextAlignment) {
        
        let detailsLabels: [TTTAttributedLabel] = [aboutDetailsLabel, languageDetailsLabel]
        
        for detailLabel in detailsLabels {
            detailLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            detailLabel.delegate = self
        }
        
        aboutDetailsLabel.text = aboutDetails
        languageDetailsLabel.text = languageDetails
        
        var maxDetailLabelHeight: CGFloat = 0
        
        for detailLabel in detailsLabels {
            detailLabel.textAlignment = textAlignment
            detailLabel.setLineSpacing(lineSpacing: 3)
            detailLabel.layoutIfNeeded()
            if detailLabel.frame.size.height > maxDetailLabelHeight {
                maxDetailLabelHeight = detailLabel.frame.size.height
            }
        }
        
        detailsLabelsViewHeight.constant = maxDetailLabelHeight
        detailsView.layoutIfNeeded()
    }
    
    private func displayButton() {
        if resource!.numberOfAvailableLanguages() == 0 {
            mainButton.designAsUnavailableButton()
        } else if resource!.shouldDownload {
            mainButton.designAsDeleteButton()
        } else {
            mainButton.designAsDownloadButton()
        }
    }
    
    private func loadDescription() -> String {
        let languagesManager = LanguagesManager()
        
        guard let language = languagesManager.loadPrimaryLanguageFromDisk() else {
            return resource!.descr ?? ""
        }
        
        if let translation = resource!.getTranslationForLanguage(language) {
            return translation.localizedDescription ?? ""
        }
        
        return resource!.descr ?? ""
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
        
        if resourceId != resource!.remoteId {
            return
        }
        
        guard let progress = notification.userInfo![GTConstants.kDownloadProgressProgressKey] as? Progress else {
            return
        }
        
        OperationQueue.main.addOperation {
            self.downloadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
            
            if progress.fractionCompleted == 1.0 {
                self.returnToHome()
            }
        }
    }
    
    @objc func handleOpenTool(button: UIButton) {
        guard let resource = resource else {
            assertionFailure("Resource should not be nil.")
            return
        }
        delegate?.openToolTapped(toolDetail: self, resource: resource)
    }
    
    @IBAction func mainButtonWasPressed(_ sender: Any) {
        
        self.baseDelegate?.goHome()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            if self.resource!.shouldDownload {
                DownloadedResourceManager().delete(self.resource!)
                self.downloadProgressView.setProgress(0.0, animated: false)
                NotificationCenter.default.post(name: .reloadHomeListNotification, object: nil)
            } else {
                DownloadedResourceManager().download(self.resource!)
            }
        }
        self.displayButton()
    }
    
    private func returnToHome() {
        let time = DispatchTime.now() + 0.55
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.baseDelegate?.goHome()
        }
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Tool Info"
    }
    
    override func siteSection() -> String {
        return "tools"
    }
    
    override func siteSubSection() -> String {
        return "add tools"
    }
    
}

extension ToolDetailViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - GTSegmentedControlDelegate

extension ToolDetailViewController: GTSegmentedControlDelegate {
    
    func segmentedControl(segmentedControl: GTSegmentedControl, didSelect segment: GTSegment, at index: Int) {
        
        if let segmentId = SegmentedControlId(rawValue: segment.id) {
                    
            switch segmentId {
            case .about:
                aboutDetailsLabelLeading.constant = 0
                languageDetailsLabelLeading.constant = view.bounds.size.width
            case .language:
                aboutDetailsLabelLeading.constant = view.bounds.size.width * -1
                languageDetailsLabelLeading.constant = 0
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.detailsView.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension ToolDetailViewController: WKYTPlayerViewDelegate {
    
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
