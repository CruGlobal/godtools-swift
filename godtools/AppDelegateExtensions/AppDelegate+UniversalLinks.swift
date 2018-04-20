//
//  AppDelegate+UniversalLinks.swift
//  godtools
//
//  Created by Ryan Carlson on 7/14/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import PromiseKit

extension AppDelegate {
    
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
        return languagesManager.loadFromDisk(code: "en")
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
