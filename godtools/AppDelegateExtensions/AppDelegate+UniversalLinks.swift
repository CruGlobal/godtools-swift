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
            self.flowController?.goToUniversalLinkedResource(resource, language: language, page: pageNumber)
        }
        return true
    }
    
    private func parseLangaugeFrom(_ url: URL) -> Language? {
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
}
