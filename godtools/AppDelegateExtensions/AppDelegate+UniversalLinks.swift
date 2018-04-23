//
//  AppDelegate+UniversalLinks.swift
//  godtools
//
//  Created by Ryan Carlson on 7/14/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit

extension AppDelegate {
    
    static let kCustomURLScheme = "godToolsCustomUrlScheme://"
    
    static let gtURL = URL(string: "itms-apps://itunes.apple.com/app/godtools/id542773210?ls=1&mt=8")
    
    static let appStoreAppID = "542773210?ls=1&mt=8"
    

    
    class func openCustomApp() {
        if openCustomURLScheme(customURLScheme: kCustomURLScheme) {
            // app was opened successfully
        } else {
            // handle unable to open the app, perhaps redirect to the App Store
            UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/app/id" + appStoreAppID)!)
        }
    }
    
    
    class func openCustomURLScheme(customURLScheme: String) -> Bool {
        guard let customURL = URL(string: customURLScheme) else { return false }
        if UIApplication.shared.canOpenURL(customURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(customURL, options: [:], completionHandler: { (true) in
                    // Do something here?
                })
            } else {
                UIApplication.shared.openURL(customURL)
            }
            return true
        }
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let message = url.host?.removingPercentEncoding
        let alertController = UIAlertController(title: "Incoming Message", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        guard let language = parseLangaugeFrom(url) else {
            return false
        }
        
        guard let resource = parseResourceFrom(url) else {
            return false
        }
        
        let pageNumber = parsePageNumberFrom(url)
        
        _ = ensureResourceIsAvailable(resource: resource, language: language).then { (success) -> Void in
            if success {
                guard let platformFlowController = self.flowController as? PlatformFlowController else {
                    return
                }
                platformFlowController.goToUniversalLinkedResource(resource, language: language, page: pageNumber)
            }
            else {
                self.fallbackToOtherLanguage(url: url)
            }
        }
        return true
    }
    
    private func parseLangaugeFrom(_ url: URL) -> Language? {
        // URL PATHCOMPONENTS example -> [ "/", "fr", "kgp", "2"]
        // PATHCOMPONENT[1] = language code
        // PATHCOMPONENT[2] = resource code (Tract)
        // PATHCOMPONENt[3] = page number (of Tract)
        // let url2 = URL(string: "http://d14vilcp0lqeut.cloudfront.net/fr/kgp/2")
        let pathParts = url.pathComponents
        
        if pathParts.count < 2 {
            return nil
        }
        
        let languagesManager = LanguagesManager()
        return languagesManager.loadFromDisk(code: pathParts[1])
    }
    
    private func parseResourceFrom(_ url: URL) -> DownloadedResource? {
        let pathParts = url.pathComponents
        
        if pathParts.count < 3 {
            return nil
        }
        
        let resourcesManager = DownloadedResourceManager()
        return resourcesManager.loadFromDisk(code: pathParts[2])
    }
    
    private func parsePageNumberFrom(_ url: URL) -> Int {
        let pathParts = url.pathComponents
        
        if pathParts.count < 4 {
            return 0
        }
        
        return Int(pathParts[3]) ?? 0
    }
    
    private func ensureResourceIsAvailable(resource: DownloadedResource, language: Language) -> Promise<Bool> {
        guard let translation = resource.getTranslationForLanguage(language) else {
            return Promise(value: false)
        }
        
        if translation.isDownloaded {
            return Promise(value: true)
        }
        
        let importer = TranslationZipImporter()
        
        return importer.downloadSpecificTranslation(translation).then { (obj) -> Promise<Bool> in
            return Promise(value: true)
        }
    }
    
    private func parseEnglishFrom(_ url: URL) -> Language? {

        let pathParts = url.pathComponents
        
        if pathParts.count < 2 {
            return nil
        }
        
        let languagesManager = LanguagesManager()
        var language: Language?
        
        switch pathParts.count {

        case 5:
           language = returnAlternateLanguage(pathParts, primary: 1, secondary: 4, manager: languagesManager)
        case 6:
            language = returnAlternateLanguage(pathParts, primary: 1, secondary: 5, manager: languagesManager)
        case 7:
            language = returnAlternateLanguage(pathParts, primary: 1, secondary: 6, manager: languagesManager)
        default:
            language = languagesManager.loadFromDisk(code: "en")
        }
        // TODO: - Find out where in the URL we are putting fallbacks
        return language
    }
    
    private func returnAlternateLanguage(_ pathParts: [String], primary: Int, secondary: Int, manager: LanguagesManager) -> Language? {
        if let languagePrimary = manager.loadFromDisk(code: pathParts[primary])  {
            return languagePrimary
        } else if let languageSecondary = manager.loadFromDisk(code: pathParts[secondary]) {
            return languageSecondary
        } else {
            return manager.loadFromDisk(code: "en")
        }
        
    }
    
    private func fallbackToOtherLanguage(url: URL)  {
        
        guard let language = parseEnglishFrom(url) else {
            return
        }
        
        guard let resource = parseResourceFrom(url) else {
            return 
        }
        
        let pageNumber = parsePageNumberFrom(url)
        
        _ = ensureResourceIsAvailable(resource: resource, language: language).then { (success) -> Void in
            if success {
                guard let platformFlowController = self.flowController as? PlatformFlowController else {
                    return
                }
                platformFlowController.goToUniversalLinkedResource(resource, language: language, page: pageNumber)
            }
            else {
                let backupURL = URL(string: "https://www.knowgod.com/")!
                UIApplication.shared.openURL(backupURL)
            }
        }
        
    }
}
