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
    dynamic var bannerRemoteId: String?
    dynamic var aboutBannerRemoteId: String?
    dynamic var code = ""
    dynamic var copyrightDescription: String?
    dynamic var name = ""
    dynamic var descr: String?
    dynamic var remoteId = ""
    dynamic var shouldDownload = false
    dynamic var totalViews: Int32 = 0
    dynamic var myViews: Int32 = 0
    let attachments = List<Attachment>()
    let translations = List<Translation>()
    
    override static func primaryKey() -> String {
        return "remoteId"
    }
    
    func numberOfAvailableLanguages() -> Int {
        return translations.filter( {$0.isPublished} ).count
    }
    
    func isAvailableInLanguage(_ language: Language?) -> Bool {
        return queryStatusWithRegardToLanuguage(language, downloaded: false)
    }
    
    func isDownloadedInLanguage(_ language: Language?) -> Bool {
        return queryStatusWithRegardToLanuguage(language, downloaded: true)
    }
    
    private func queryStatusWithRegardToLanuguage(_ language: Language?, downloaded: Bool) -> Bool {
        guard let language = language else {
            return false
        }
        let languageId = language.remoteId
        
        var predicate: NSPredicate
            
        if downloaded {
            predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true AND isDownloaded = true", languageId)
        } else {
            predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true", languageId)
        }
        
        let matchingTranslations = translations.filter(predicate).count > 0
        
        return matchingTranslations
    }
    
    func getTranslationForLanguage(_ language: Language) -> Translation? {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND isDownloaded = true", language.remoteId)
        
        return translations.filter(predicate).first
    }
    
    func localizedName(language: Language?) -> String {
        guard let language = language else {
            return name
        }
        
        if isDownloadedInLanguage(language) {
            guard let translation = getTranslationForLanguage(language) else {
                return name
            }
            
            return translation.localizedName ?? name
        }
        
        return name
    }
}
