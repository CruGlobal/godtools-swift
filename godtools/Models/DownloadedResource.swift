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
