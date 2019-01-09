//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//


import TTTAttributedLabel
import UIKit


class ToolDetailViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak var descriptionLabel: GTLabel! {
        didSet {
            descriptionLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            descriptionLabel.delegate = self
        }
    }
    @IBOutlet weak var totalLanguagesLabel: GTLabel!
    @IBOutlet weak var languagesLabel: GTLabel!
    @IBOutlet weak var mainButton: GTButton!
    @IBOutlet weak var downloadProgressView: GTProgressView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    
    let toolsManager = ToolsManager.shared
    
    var resource: DownloadedResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayData()
        self.hideScreenTitle()
        registerForDownloadProgressNotifications()
        setTopHeight()
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
        
        self.totalViewsLabel.text = String.localizedStringWithFormat("total_views".localized, resource.totalViews)
        
        self.totalLanguagesLabel.text = String.localizedStringWithFormat("total_languages".localized, resource.numberOfAvailableLanguages())
        
        self.titleLabel.text = resource.localizedName(language: primaryLanguage)
        
        self.descriptionLabel.text = loadDescription()
        
        let resourceTranslations = Array(resource.translations)
        var translationStrings = [String]()
        for translation in resourceTranslations {
            guard translation.language != nil else {
                continue
            }
            guard let languageLocalName = translation.language?.localizedName() else {
                continue
            }
            translationStrings.append(languageLocalName)
        }
        let labelText = translationStrings.sorted(by: { $0 < $1 }).joined(separator: ", ")
        
        self.languagesLabel.text = labelText
        self.displayButton()
        self.bannerImageView.image = BannerManager().loadFor(remoteId: resource.aboutBannerRemoteId)
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
    
    @IBAction func mainButtonWasPressed(_ sender: Any) {
        if resource!.shouldDownload {
            DownloadedResourceManager().delete(self.resource!)
            downloadProgressView.setProgress(0.0, animated: false)
        } else {
            DownloadedResourceManager().download(self.resource!)
        }
        displayButton()
        returnToHome()
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

