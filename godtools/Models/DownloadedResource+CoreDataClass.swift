//
//  DownloadedResource+CoreDataClass.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData

@objc(DownloadedResource)
public class DownloadedResource: NSManagedObject {

    func numberOfAvailableLanguages() -> Int {
        return translationsAsArray().filter( {$0.isPublished} ).count
    }
    
    func isAvailableInLanguage(_ language: Language?) -> Bool {
        if language == nil {
            return false
        }
        
        return translationsAsArray().filter({ $0.language!.remoteId == language!.remoteId })
            .filter({ $0.isPublished} ).count > 0
    }
    
    func getTranslationForLanguage(_ language: Language) -> Translation? {
        return translationsAsArray().filter({ $0.language!.remoteId == language.remoteId })
            .filter({ $0.isDownloaded })
            .max(by: { $0.version < $1.version })
    }
    
    func latestTranslationId() -> String? {
        let translationsArray = Array(translations!) as! [Translation]
        
        let latestTranslation = translationsArray
            .filter( {$0.isPublished} )
            .filter( {$0.downloadedResource == self} )
            .filter( {$0.language?.remoteId == GTSettings.shared.primaryLanguageId} )
            .max(by: {$0.version < $1.version} )
        
        return latestTranslation?.remoteId!
    }
    
    func translationsAsArray() -> [Translation] {
        return Array(translations!) as! [Translation]
    }
    
    func localizedName(language: Language?) -> String {
        guard let language = language else {
            return name!
        }
        
        if isAvailableInLanguage(language) {
            guard let translation = getTranslationForLanguage(language) else {
                return name!
            }
            
            return translation.localizedName ?? name!
        }
        
        return name!
    }
}
