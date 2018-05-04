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
    static let appStoreAppID = "542773210"
    static let kPrimaryLanguageKey = "primaryLanguage"
    static let kParallelLanguageKey = "parallelLanguage"
    static let kMcidKey = "mcid"
    
    // NEW URL Structure!! h ttp://knowgod.com/en/fourlaws/3?primaryLanguage=ts,ar,fr-CA,en&mcid=6jaskdf&parallelLanguage=ez,fz,zh-hans,en
    
    // PATHCOMPONENT[0] = "/"
    // PATHCOMPONENT[1] = known language code
    // PATHCOMPONENT[2] = tract
    // PATHCOMPONENT[3] = page number
    // PATHCOMPONENt[4] = query for possible languages and other parameters
    
    // MARK: - This is for use when coming from JesusFilm App (or other Apps) that have our URL scheme registered in their whitelist.
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        processForDeepLinking(from: url)
        
        return true
    }
    
    // MARK: - This is for use when coming from Safari or Universal Links.
    
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
        
        let languageOptions = parseLanguagesFrom(url, usingKey: AppDelegate.kPrimaryLanguageKey)
        
        guard let resource = parseResourceFrom(url) else {
            return
        }
        
        guard let language = getLanguageFor(resource: resource, languageOptions: languageOptions) else {
            return
            
        }
        
        let pageNumber = parsePageNumberFrom(url) ?? 0
        
        _ = ensureResourceIsAvailable(resource: resource, language: language).then { (success) -> Void in
            if success {
                guard let platformFlowController = self.flowController as? PlatformFlowController else {
                    return
                }
                platformFlowController.goToUniversalLinkedResource(resource, language: language, page: pageNumber, parallelLanguageCode: nil)
            }
            else if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func getLanguageFor(resource: DownloadedResource, languageOptions: [Language]) -> Language? {
        var checkedLanguages: [Language] = []
        for language in languageOptions {
            if resource.isAvailableInLanguage(language) {
                checkedLanguages.append(language)
            }
        }
        return checkedLanguages.first
    }
    
    // MARK: - Returns Languages from the query portion of a URL, using a given key - ie., primaryLanguage, parallelLanguage, etc,.
    
    private func parseLanguagesFrom(_ url: URL, usingKey: String) -> [Language] {
        let languagesManager = LanguagesManager()
        var tryLanguages: [Language] = []
        let knownLanguageString = url.pathComponents[1]
        guard let knownLanguage = returnAlternateLanguage(from: knownLanguageString) else { return tryLanguages }
        tryLanguages.append(knownLanguage)
        var linkDictionary: [String: Any] = [:]
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return tryLanguages }
        guard let componentItems = components.queryItems else { return tryLanguages }
        
        for item in componentItems {
            linkDictionary[item.name] = item.value ?? ""
        }
        
        let languages = linkDictionary[usingKey] as? String ?? ""
        
        let languageOptions = languages.components(separatedBy: ",")
        if languageOptions.isEmpty { return tryLanguages }
        tryLanguages.remove(at: 0)
        
        tryLanguages = languageOptions.flatMap { languagesManager.loadFromDisk(code: $0) }
        tryLanguages.append(knownLanguage)
        
        return tryLanguages
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
    
    // MARK: - If there is a parallel Language given in the query, this validates for that Language and downloads the translation (if needed).
    
    private func verifyResource(resource: DownloadedResource, language: Language)  {
        
        guard let translation = resource.getTranslationForLanguage(language) else {
            return
        }
        
        if translation.isDownloaded {
            return
        }
        
        let importer = TranslationZipImporter()
        
        let _ = importer.downloadSpecificTranslation(translation)
    }
    
    // MARK: - This is a streamlined way to return a known Language, or fallback and return English.
    
    private func returnAlternateLanguage(from code: String = "en") -> Language? {
        let languagesManager = LanguagesManager()
        return languagesManager.loadFromDisk(code: code)
    }
    
    // MARK: - Analytics helper...criteria not yet defined.
    
    func sendAnalyticsData(from url: URL, usingKey: String) {
        var linkDictionary: [String: Any] = [:]
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        guard let componentItems = components.queryItems else { return }
        
        for item in componentItems {
            linkDictionary[item.name] = item.value ?? ""
        }
        
        let analyticsId = linkDictionary[usingKey] as? String ?? ""
        
        // Do something for analytics here?
        debugPrint("\(analyticsId)")
    }
    
}
