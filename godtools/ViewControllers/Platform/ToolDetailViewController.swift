//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//


import TTTAttributedLabel
import UIKit

protocol ToolDetailViewControllerDelegate: class {
    func openToolTapped(toolDetail: ToolDetailViewController, resource: DownloadedResource)
}

class ToolDetailViewController: BaseViewController {
    
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak var descriptionLabel: GTAttributedLabel! {
        didSet {
            descriptionLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            descriptionLabel.delegate = self
        }
    }
    @IBOutlet weak var totalLanguagesLabel: GTLabel!
    @IBOutlet weak var languagesLabel: GTLabel!
    @IBOutlet weak var openToolButton: GTButton!
    @IBOutlet weak var mainButton: GTButton!
    @IBOutlet weak var downloadProgressView: GTProgressView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var aboutLabel: GTLabel!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTopToTotalViewsLabel: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTopToOpenToolButton: NSLayoutConstraint!
    
    
    let toolsManager = ToolsManager.shared
    
    var resource: DownloadedResource?
    
    weak var delegate: ToolDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openToolButton.designAsOpenToolButton()
        openToolButton.addTarget(self, action: #selector(handleOpenTool(button:)), for: .touchUpInside)
        self.displayData()
        self.hideScreenTitle()
        registerForDownloadProgressNotifications()
        setTopHeight()
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
        
        // if tool is available in primary language, attempt to retrieve string based on that lanague else default to device language
        let localizedTotalViews = resource.isAvailableInLanguage(primaryLanguage) ? "total_views".localized(for: primaryLanguage?.code) ?? "total_views".localized : "total_views".localized
        self.totalViewsLabel.text = String.localizedStringWithFormat(localizedTotalViews, resource.totalViews)
        
        let localizedTotalLanguages =  resource.isAvailableInLanguage(primaryLanguage) ? "total_languages".localized(for: primaryLanguage?.code) ?? "total_languages".localized : "total_languages".localized
        self.totalLanguagesLabel.text = String.localizedStringWithFormat(localizedTotalLanguages.localized, resource.numberOfAvailableLanguages())
        
        let localizedAbout = resource.isAvailableInLanguage(primaryLanguage) ? "about".localized(for: primaryLanguage?.code) ?? "about".localized : "about".localized
        self.aboutLabel.text = String.localizedStringWithFormat(localizedAbout, resource.totalViews)

        self.titleLabel.text = resource.localizedName(language: primaryLanguage)
        
        self.descriptionLabel.text = loadDescription()
        
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
        let labelText = translationStrings.sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        self.languagesLabel.text = labelText
        self.displayButton()
        self.bannerImageView.image = BannerManager().loadFor(remoteId: resource.aboutBannerRemoteId)
        
        let textAlignment: NSTextAlignment = (resource.isAvailableInLanguage(primaryLanguage) && primaryLanguage?.isRightToLeft() ?? false) ? .right : .natural
        descriptionLabel.textAlignment = textAlignment
        titleLabel.textAlignment = textAlignment
        totalViewsLabel.textAlignment = textAlignment
        aboutLabel.textAlignment = textAlignment
        totalLanguagesLabel.textAlignment = textAlignment
        languagesLabel.textAlignment = textAlignment
    }
    
    private var showsOpenToolButton: Bool {
        return resource?.shouldDownload ?? false
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

