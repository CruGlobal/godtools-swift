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
    
    // MARK: - Data that may be relevant to give to Jesus Film Project
    
    static let kCustomURLScheme = "GodTools://"
    
    static let appStoreGodToolsURL = URL(string: "itms-apps://itunes.apple.com/app/godtools/id542773210?ls=1&mt=8")
    
    static let appStoreAppID = "542773210?ls=1&mt=8"
    
    // NEW URL Structure!! h ttp://knowgod.com/en/fourlaws?primaryLanguage=ts,ar,fr-CA,en
    
    // PATHCOMPONENT[0] = "/"
    // PATHCOMPONENT[1] = known language code
    // PATHCOMPONENT[2] = tract
    // PATHCOMPONENT[3] = page number
    // PATHCOMPONENt[4] = query for possible languages and other parameters
    
    // MARK: - This is for using when coming from JesusFilm App.
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        processForDeepLinking(from: url)
        
        return true
    }
    
    // MARK: - This is for using when coming from Safari.
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        processForDeepLinking(from: url)
        
        return true
    }
    
    private func processForDeepLinking(from url: URL) {
        let knownLanguage = url.pathComponents[1]

        guard let language = parseUsableLanguageFrom(url) ?? returnAlternateLanguage(from: knownLanguage) else {
             return
        }
        
        guard let resource = parseResourceFrom(url) else {
            return
        }
        
        let pageNumber = parsePageNumberFrom(url) ?? 0
        
        _ = ensureResourceIsAvailable(resource: resource, language: language).then { (success) -> Void in
            if success {
                guard let platformFlowController = self.flowController as? PlatformFlowController else {
                    return
                }
                platformFlowController.goToUniversalLinkedResource(resource, language: language, page: pageNumber)
            }
            else {
                self.fallbackToEnglish(url: url)
            }
        }
    }
    
    private func parseUsableLanguageFrom(_ url: URL) -> Language? {
        let languagesManager = LanguagesManager()
        var linkDictionary: [String: Any] = [:]
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        guard let componentItems = components.queryItems else { return nil }
        
        for item in componentItems {
            linkDictionary[item.name] = item.value ?? ""
        }
        
        let languages = linkDictionary["primaryLanguage"] as? String ?? ""
        
        let parallelLanguages = linkDictionary["parallelLanguage"] as? String ?? ""
        if let parallelLanguage = getParallelLanguage(using: languagesManager, parallelLanguages: parallelLanguages) {
            handleTheParallelLanguage(parallelLanguage)
        }
        
        let analyticsId = linkDictionary["mcid"] as? String ?? ""
        sendAnalyticsData(fromString: analyticsId)
        
        let languageOptions = languages.components(separatedBy: ",")
        if languageOptions.isEmpty { return nil }
        
        let tryLanguages = languageOptions.flatMap { languagesManager.loadFromDisk(code: $0) }
        return tryLanguages.first
    }
    
    private func handleTheParallelLanguage(_ language: Language) {
        // Do something with the parallel language?
    }
    
    private func getParallelLanguage(using languagesManager: LanguagesManager, parallelLanguages: String) -> Language? {
        let languageOptions = parallelLanguages.components(separatedBy: ",")
        let tryLanguages = languageOptions.flatMap { languagesManager.loadFromDisk(code: $0) }
        return tryLanguages.first
        
    }
    
    private func parseResourceFrom(_ url: URL) -> DownloadedResource? {
        let pathParts = url.pathComponents
        
        if pathParts.count < 3 {
            return nil
        }
        
        let resourcesManager = DownloadedResourceManager()
        return resourcesManager.loadFromDisk(code: pathParts[2])
    }
    
    private func parsePageNumberFrom(_ url: URL) -> Int? {
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
    
    private func returnAlternateLanguage(from code: String = "en") -> Language? {
        let languagesManager = LanguagesManager()
        return languagesManager.loadFromDisk(code: code)
    }
    
    private func fallbackToEnglish(url: URL)  {
        
        guard let language = returnAlternateLanguage() else {
            return
        }
        
        guard let resource = parseResourceFrom(url) else {
            return 
        }
        
        let pageNumber = parsePageNumberFrom(url) ?? 0
        
        _ = ensureResourceIsAvailable(resource: resource, language: language).then { (success) -> Void in
            if success {
                guard let platformFlowController = self.flowController as? PlatformFlowController else {
                    return
                }
                platformFlowController.goToUniversalLinkedResource(resource, language: language, page: pageNumber)
            }
            else {
                let backupURL = URL(string: "https://www.knowgod.com/")!
                UIApplication.shared.open(backupURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func sendAnalyticsData(fromString: String) {
        debugPrint("\(fromString)")
    }
    
}
