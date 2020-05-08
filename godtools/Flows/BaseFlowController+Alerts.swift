//
//  BaseFlowController+Alerts.swift
//  godtools
//
//  Created by Ryan Carlson on 7/3/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension BaseFlowController {
    
    func showDeviceLocaleDownloadedAndSwitchPrompt() {
        let languagesManager = LanguagesManager()
        
        guard languagesManager.loadNonEnglishPreferredLanguageFromDisk() != nil else {
            return
        }
        
        let alert = UIAlertController(title: "",
                                      message: "device_locale_download_success".localized,
                                      preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "yes".localized, style: .default) { (action) in
            languagesManager.setPrimaryLanguageForInitialDeviceLanguageDownload()
            TranslationZipImporter().catchupMissedDownloads()
        }
        
        let noAction = UIAlertAction(title: "no".localized, style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        currentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showDeviceLocaleDownloadFailedAlert() {
        let languagesManager = LanguagesManager()

        guard languagesManager.loadNonEnglishPreferredLanguageFromDisk() != nil else {
            return
        }
        
        
        let alert = UIAlertController(title: "download_error".localized,
                                      message: "device_locale_download_error".localized,
                                      preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "dismiss".localized,
                                          style: .default)
        
        alert.addAction(dismissAction)
        
        currentViewController?.present(alert, animated: true, completion: nil)
    }
}
