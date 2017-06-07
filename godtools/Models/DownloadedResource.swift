//
//  DownloadedResource.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class DownloadedResource: Object {
    dynamic var bannerRemoteId: String?
    dynamic var code = ""
    dynamic var copyrightDescription: String?
    dynamic var name = ""
    dynamic var remoteId = ""
    dynamic var shouldDownload = false
    dynamic var totalViews: Int32 = 0
    dynamic var myViews: Int32 = 0
    let attachments = List<Attachment>()
    let translations = List<Translation>()
    
    func numberOfAvailableLanguages() -> Int {
        return translations.filter( {$0.isPublished} ).count
    }
    
    func isAvailableInLanguage(_ language: Language?) -> Bool {
        if language == nil {
            return false
        }
        
        return translations.filter({ $0.language!.remoteId == language!.remoteId })
            .filter({ $0.isPublished} ).count > 0
    }
    
    func getTranslationForLanguage(_ language: Language) -> Translation? {
        return translations.filter({ $0.language!.remoteId == language.remoteId })
            .filter({ $0.isDownloaded })
            .max(by: { $0.version < $1.version })
    }
    
    func latestTranslationId() -> String? {
        let latestTranslation = translations
            .filter( {$0.isPublished} )
            .filter( {$0.downloadedResource == self} )
            .filter( {$0.language?.remoteId == GTSettings.shared.primaryLanguageId} )
            .max(by: {$0.version < $1.version} )
        
        return latestTranslation?.remoteId
    }
    
    func localizedName(language: Language?) -> String {
        guard let language = language else {
            return name
        }
        
        if isAvailableInLanguage(language) {
            guard let translation = getTranslationForLanguage(language) else {
                return name
            }
            
            return translation.localizedName! 
        }
        
        return name
    }
}
