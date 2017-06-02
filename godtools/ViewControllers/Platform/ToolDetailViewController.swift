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
        self.totalViewsLabel.text = String.localizedStringWithFormat("total_views".localized, resource!.totalViews)
        self.totalLanguagesLabel.text = String.localizedStringWithFormat("total_languages".localized, resource!.numberOfAvailableLanguages())
        self.titleLabel.text = resource!.localizedName(language: LanguagesManager.shared.loadPrimaryLanguageFromDisk())

        self.languagesLabel.text = Array(resource!.translations!)
            .map({ "\(($0 as! Translation).language!.localizedName())"})
            .sorted(by: { $0 < $1 })
            .joined(separator: ", ")
        
        self.displayButton()
        self.bannerImageView.image = BannerManager.shared.loadFor(resource!)
    }
    
    private func displayButton() {
        if resource!.shouldDownload {
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
        
        if resourceId != resource!.remoteId! {
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
            toolsManager.delete(resource: self.resource!)
            downloadProgressView.setProgress(0.0, animated: false)
            displayButton()
            returnToHome()
        } else {
            toolsManager.download(resource: self.resource!)
            displayButton()
        }
    }
    
    private func returnToHome() {
        let time = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.baseDelegate?.goHome()
        }
    }
}
