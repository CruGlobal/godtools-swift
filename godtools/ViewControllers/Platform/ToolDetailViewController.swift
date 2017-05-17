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
        self.totalLanguagesLabel.text = String.localizedStringWithFormat("total_languages".localized, "40")
        self.titleLabel.text = resource?.name

        self.languagesLabel.text = Array(resource!.translations!)
            .map({ "\(($0 as! Translation).language!.localizedName())"})
            .sorted(by: { $0 < $1 })
            .joined(separator: ", ")
        
        self.displayButton()
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
        
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
        }
    }
    
    @IBAction func mainButtonWasPressed(_ sender: Any) {
        if resource!.shouldDownload {
            toolsManager.delete(resource: self.resource!)
            downloadProgressView.setProgress(0.0, animated: false)
            displayButton()
        } else {
            toolsManager.download(resource: self.resource!)
            displayButton()
        }
    }
}
