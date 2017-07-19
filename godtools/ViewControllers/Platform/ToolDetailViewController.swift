//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ToolDetailViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak var descriptionLabel: GTLabel!
    @IBOutlet weak var totalLanguagesLabel: GTLabel!
    @IBOutlet weak var languagesLabel: GTLabel!
    @IBOutlet weak var mainButton: GTButton!
    @IBOutlet weak var downloadProgressView: GTProgressView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    let toolsManager = ToolsManager.shared
    
    var resource: DownloadedResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayData()
        self.hideScreenTitle()
        registerForDownloadProgressNotifications()
    }

    // MARK: Present data
    
    fileprivate func displayData() {
        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
        
        self.totalViewsLabel.text = String.localizedStringWithFormat("total_views".localized, resource!.totalViews)
        self.totalViewsLabel.font = self.totalViewsLabel.font.transformToAppropriateFont()
        
        self.totalLanguagesLabel.text = String.localizedStringWithFormat("total_languages".localized, resource!.numberOfAvailableLanguages())
        self.totalLanguagesLabel.font = self.totalLanguagesLabel.font.transformToAppropriateFont()
        
        self.titleLabel.text = resource!.localizedName(language: primaryLanguage)
        self.titleLabel.font = self.titleLabel.font.transformToAppropriateFont()
        
        self.descriptionLabel.text = loadDescription()
        self.descriptionLabel.font = self.descriptionLabel.font.transformToAppropriateFont()
        
        self.languagesLabel.text = Array(resource!.translations)
            .map({ "\($0.language!.localizedName())"})
            .sorted(by: { $0 < $1 })
            .joined(separator: ", ")
        self.languagesLabel.font = self.languagesLabel.font.transformToAppropriateFont()
        
        self.displayButton()
        self.bannerImageView.image = BannerManager().loadFor(remoteId: resource!.aboutBannerRemoteId)
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
}
