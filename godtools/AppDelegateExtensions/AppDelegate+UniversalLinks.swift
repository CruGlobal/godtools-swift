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
    
    static let kCustomURLScheme = "GodTools://"
    
    static let appStoreGodToolsURL = URL(string: "itms-apps://itunes.apple.com/app/godtools/id542773210?ls=1&mt=8")
    
    static let appStoreAppID = "542773210?ls=1&mt=8"
    
    // MARK: - URL Structure: "h ttp://d14vilcp0lqeut.cloudfront.net/fr/kgp/2")
    // New URL Structure: http://knowgod.com/en/fourlaws?primaryLanguage=ts,ar,fr-CA,en
    //                   https://knowgod.com/ar/fourlaws/4
    // URL PATHCOMPONENTS example -> [ "/", "fr", "kgp", "2"]
    // PATHCOMPONENT[0] = "/"
    // PATHCOMPONENT[1] = language code
    // PATHCOMPONENT[2] = resource code (Tract)
    // PATHCOMPONENt[3] = page number (of Tract)
    
    
    // New URL Structure!!!!!!!!!!!!!
    // PATHCOMPONENT[0] = ?
    // PATHCOMPONENT[1] = ?
    // PATHCOMPONENT[2] = ?
    // PATHCOMPONENt[3] = ?
    // PATHCOMPONENT[4] = ?
    // PATHCOMPONENT[5] = ?
    // PATHCOMPONENT[6] = ?
    // PATHCOMPONENt[7] = ?
    
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
//        let path = url.path
//        guard let queryParts = url.query else { return }
//        let languageOptions = filterURLQuery(queryString: queryParts)
        
        guard let language = parseLangaugeFrom(url) else {
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
                self.fallbackToOtherLanguage(url: url)
            }
        }
    }
    
    private func filterURLQuery(queryString: String) -> [String] {
        var languageOptions: [String] = []
        let languageParts = queryString.components(separatedBy: ",")
        for language in languageParts {
            if language.contains("=") {
                languageOptions.append(handleEqualSign(stringWithEquals: language))
            } else {
                languageOptions.append(language)
            }
        }
        return languageOptions
    }
    
    private func handleEqualSign(stringWithEquals: String) -> String {
        let languageExtras = stringWithEquals.components(separatedBy: "=")
        return languageExtras.last ?? ""
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
    
    private func parseUsableLanguageFrom(_ url: URL) -> Language? {
        let languagesManager = LanguagesManager()
        
        guard let queryParts = url.query else { return nil }
        let languageOptions = filterURLQuery(queryString: queryParts)
        
        if languageOptions.isEmpty {
            return languagesManager.loadFromDisk(code: "en")
        }
        
        var language: Language?
        
        // TODO: - Find out where in the URL we are putting fallbacks??
        
        switch languageOptions.count {

        case 2:
           language = returnAlternateLanguage(languageOptions, primary: 0, secondary: 1, manager: languagesManager)
        case 3:
            language = returnAlternateLanguage(languageOptions, primary: 0, secondary: 1, manager: languagesManager)
        case 4:
            language = returnAlternateLanguage(languageOptions, primary: 0, secondary: 1, manager: languagesManager)
        default:
            language = languagesManager.loadFromDisk(code: "en")
        }
        
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
        
        guard let language = parseUsableLanguageFrom(url) else {
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
                UIApplication.shared.open(backupURL, options: [:], completionHandler: nil)
            }
        }
        
    }
    
}
