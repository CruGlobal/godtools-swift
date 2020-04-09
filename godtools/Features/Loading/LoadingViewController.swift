//
//  LoadingViewController.swift
//  godtools
//
//  Created by Greg Weiss on 5/18/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var downloadProgressView: GTProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingLabel.text = "the_tool_you_requested_is_loading".localized
        downloadProgressView.setProgress(0.0, animated: true)
        registerForDownloadProgressNotifications()

    }
    
    // MARK: Progress view listener
    
    private func registerForDownloadProgressNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(progressViewListenerShouldUpdate),
                                               name: .downloadProgressViewUpdateNotification,
                                               object: nil)
    }
    
    @objc private func progressViewListenerShouldUpdate(notification: NSNotification) {

        guard let progress = notification.userInfo![GTConstants.kDownloadProgressProgressKey] as? Progress else {
            return
        }
        
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
        }
    }
 
}
