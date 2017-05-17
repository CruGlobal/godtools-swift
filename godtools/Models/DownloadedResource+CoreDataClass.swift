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

    func isAvailableInLanguage(_ language: Language) -> Bool {
        guard let translationsSet = self.translations else {
            return false
        }
        
        for translation in Array(translationsSet) {
            if (translation as! Translation).language!.remoteId == language.remoteId {
                return true
            }
        }
        
        return false
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
}
