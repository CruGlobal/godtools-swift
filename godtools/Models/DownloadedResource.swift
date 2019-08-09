//
//  DownloadedResource.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

typealias DownloadedResources = List<DownloadedResource>

class DownloadedResource: Object {
    @objc dynamic var bannerRemoteId: String?
    @objc dynamic var aboutBannerRemoteId: String?
    @objc dynamic var code = ""
    @objc dynamic var copyrightDescription: String?
    @objc dynamic var name = ""
    @objc dynamic var toolType = ""
    @objc dynamic var descr: String?
    @objc dynamic var remoteId = ""
    @objc dynamic var shouldDownload = false
    @objc dynamic var totalViews: Int32 = 0
    @objc dynamic var myViews: Int32 = 0
    
    let attachments = List<Attachment>()
    let translations = List<Translation>()
    let categories =  List<Category>()
    
    override static func primaryKey() -> String {
        return "remoteId"
    }
    
    func isReady() -> Bool {
        let languagesManager = LanguagesManager()
        let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
        let parallelLanguage = languagesManager.loadParallelLanguageFromDisk()
        
        // If the primary and parallel translations are not available and either the device preferrred language or English is available return true
        if !isAvailableInLanguage(primaryLanguage) && (!isAvailableInLanguage(parallelLanguage) || parallelLanguage == nil) {
            return isDefaultLanguageReady()
        }
        // Verify primary and parallel translations are available and have been dowloaded
        else if isPrimaryTranslationReady(language: primaryLanguage) && isParallelTranslationReady(language: parallelLanguage) {
            return true
        }

        // If we get here, the primary and/or the parrallel language translations are available but not downloaded, so return false
        return false
    }
    
    /// Returns true if the primary language translation is not available or is available and the download has completed
    private func isPrimaryTranslationReady(language: Language?) -> Bool {
        return !isAvailableInLanguage(language) || (isAvailableInLanguage(language) && isDownloadedInLanguage(language))
    }
    
    /// Returns true if the parallel language translation is not set or not available or is available and the download has completed
    private func isParallelTranslationReady(language: Language?) -> Bool {
        return language == nil || !isAvailableInLanguage(language) || (isAvailableInLanguage(language) && isDownloadedInLanguage(language)) 
    }
    
    // Returns whether the device default language translation is available and downloaded.
    // If default langauge is not available, returns whether the English translation is downloaded.
    private func isDefaultLanguageReady() -> Bool {
        let languagesManager = LanguagesManager()
        let preferredLanguage = languagesManager.loadDevicePreferredLanguageFromDisk()
        let englishLanguage = languagesManager.loadFromDisk(code: "en")
        
        if isAvailableInLanguage(preferredLanguage) {
            return isDownloadedInLanguage(preferredLanguage)
        }
        else {
            return isDownloadedInLanguage(englishLanguage)
        }
    }
    
    func numberOfAvailableLanguages() -> Int {
        return Set(translations.filter( {$0.isPublished} ) as [Translation]).count
    }
    
    func isAvailableInLanguage(_ language: Language?) -> Bool {
        return isTranslationAvailableInLanguage(language, mustItBeDownloaded: false)
    }
    
    func isDownloadedInLanguage(_ language: Language?) -> Bool {
        return isTranslationAvailableInLanguage(language, mustItBeDownloaded: true)
    }
    
    private func isTranslationAvailableInLanguage(_ language: Language?, mustItBeDownloaded: Bool) -> Bool {
        guard let language = language else {
            return false
        }
        let languageId = language.remoteId
        
        var predicate: NSPredicate
            
        if mustItBeDownloaded {
            predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true AND isDownloaded = true", languageId)
        } else {
            predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true", languageId)
        }
        
        let matchingTranslations = translations.filter(predicate).count > 0
        
        return matchingTranslations
    }
    
    func getTranslationForLanguage(_ language: Language) -> Translation? {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true", language.remoteId)
        
        return translations.filter(predicate).first
    }
    
    func localizedName(language: Language?) -> String {
        guard let language = language else {
            return name
        }
        
        if isAvailableInLanguage(language) {
            guard let translation = getTranslationForLanguage(language) else {
                return name
            }
            
            return translation.localizedName ?? name
        }
        
        return name
    }
}
