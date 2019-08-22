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
    
    // MARK: - This is for use when coming from Safari or Universal Links.
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        if let host = url.host, host.contains("godtoolsapp") {
            if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeAuthorizationFlow(with: url) {
                self.currentAuthorizationFlow = nil
                return true
            }
        } else {
            
            processForDeepLinking(from: url)
        }
        
        return true
    }
    

    
    func processForDeepLinking(from url: URL, shouldDisplayLoadingScreen: Bool = true) {
        
        let languageOptions = parseLanguagesFrom(url, usingKey: AppDelegate.kPrimaryLanguageKey)
        
        guard let resource = parseResourceFrom(url) else {
            return
        }
        
        guard let language = getLanguageFor(resource: resource, languageOptions: languageOptions) else {
            return
        }
        
        if shouldDisplayLoadingScreen {
            displayLoadingScreen()
        }

        let pageNumber = parsePageNumberFrom(url) ?? 0
        
        let parallelLanguages = parseLanguagesFrom(url, usingKey: AppDelegate.kParallelLanguageKey)

        var parallelLanguage: Language?
        
        // The language options needs more than 1 value because it will contain the known language at the end of the array and that won't be usable for parallel languages
        parallelLanguage = (parallelLanguages.count > 1) ? getLanguageFor(resource: resource, languageOptions: parallelLanguages) : nil
        
        if let parallelLang = parallelLanguage {
            
            // Need to handle this way so all resources are in place before presenting tract.
            _ = ensureResourceIsAvailable(resource: resource, language: parallelLang)
            .done { (success) -> Void in
                
                if success {
                    // Parallel language has succeeded
                    
                    _ = self.ensureResourceIsAvailable(resource: resource, language: language)
                    .done { (success) -> Void in
                        if success {
                            // Primary language has succeeded
                            // Go to that Tract with a parallel language
                            self.shouldGoToUniversalLinkedResource(resource, language: language, pageNumber: pageNumber, parallelLanguageCode: parallelLang.code)
                        }
                    }
                }
            }
        }
        
        if parallelLanguage == nil {
            _ = ensureResourceIsAvailable(resource: resource, language: language).done { (success) -> Void in
                if success {
                    self.shouldGoToUniversalLinkedResource(resource, language: language, pageNumber: pageNumber, parallelLanguageCode: parallelLanguage?.code)
                } else if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    private func shouldGoToUniversalLinkedResource(_ resource: DownloadedResource, language: Language, pageNumber: Int, parallelLanguageCode: String? = nil) {
        dismissLoadingScreen()

            guard let platformFlowController = self.flowController as? PlatformFlowController else {
                return
            }
            platformFlowController.goToUniversalLinkedResource(resource, language: language, page: pageNumber, parallelLanguageCode: parallelLanguageCode)
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
        
        if url.pathComponents.count < 2 {
            return tryLanguages
        }
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
        
        var languageOptions = languages.components(separatedBy: ",")
        if languageOptions.isEmpty { return tryLanguages }
        languageOptions = parseForSubtagsAndDialects(languageStrings: languageOptions)

        tryLanguages.remove(at: 0)
        tryLanguages = languageOptions.compactMap { languagesManager.loadFromDisk(code: $0) }
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
            return .value(false)
        }
        
        if translation.isDownloaded {
            return .value(true)
        }
        
        let importer = TranslationZipImporter()
        
        return importer.downloadSpecificTranslation(translation).then { (obj) -> Promise<Bool> in
            return .value(true)
        }
    }
    
    // MARK: - This was a request from JesusFilm to add extra fallbacks that aren't in the query
    // For a language with a subtag and/or a dialect ex: "ms-pse-x-Ogan"
    
    func parseForSubtagsAndDialects(languageStrings: [String]) -> [String] {
        
        var copiedLanguages: [String] = []
        
        for language in languageStrings {

            // Split out language components to check for subtags
            if language.contains("-") {
                let components = language.components(separatedBy: "-")
                
                // This means there is one or more subtags, so we will parse and return all options
                copiedLanguages.append(contentsOf: parseSubtagComponents(languageComponents: components))
                
            } else {
                copiedLanguages.append(language)
            }
        }
        return copiedLanguages
    }
    
    func parseSubtagComponents(languageComponents: [String]) -> [String] {
        
        // We need a mutatable copy so it can be used again as it shrinks
        var copiedComponents: [String] = languageComponents
        
        // This will be the returned output that gets appended to
        var newComponents: [String] = []
        
        // Find out how many times to iterate
        let count = languageComponents.count
        
        // No need to iterate unless there is more than one
        guard count > 1 else { return newComponents }
        
        for _ in 1...count {
            
            // This will assemble all the parts of the language together ex: ms-pse-x-Ogan-
            // Notice the extra "-" at the end. (addressed below...)
            var languageName = copiedComponents.reduce("") { part1, part2  in "\(part1)\(part2)-"}
            
            // This removes the extra "-" character
            languageName.removeLast()
            
            // This adds the assembled name to our new list, starting with full name.
            newComponents.append(languageName)
            
            // This removes the last component from our copy before we iterate through again.
            copiedComponents.removeLast()
        }
        
        // Here we now have the array of ["ms-pse-x-Ogan", "ms-pse-x", "ms-pse", "ms"]
        return newComponents
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
    
    func displayLoadingScreen() {
        let loadingViewController = LoadingViewController(nibName: String(describing:LoadingViewController.self), bundle: nil)
        if let currentViewController = self.window?.rootViewController {
            currentViewController.present(loadingViewController, animated: true, completion: nil)
        }
    }
    
    func dismissLoadingScreen() {
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
