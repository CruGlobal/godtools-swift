//
//  TranslationsManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import CoreData

class TranslationsManager: GTDataManager {
    static let shared = TranslationsManager()
    
    func translationWasDownloaded(_ translation: Translation) {
        translation.isDownloaded = true
        saveToDisk()
    }
    
    func translationsNeedingDownloaded() -> [Translation] {
        let predicate = NSPredicate(format: "language.shouldDownload = true AND downloadedResource.shouldDownload = true AND isDownloaded = false")

        return findEntities(Translation.self, matching: predicate)
    }
    
    func purgeTranslationsOlderThan(_ latest: Translation, saving: Bool) {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version < %d AND isDownloaded = %@",
                                    latest.language!.remoteId!,
                                    latest.downloadedResource!.remoteId!,
                                    latest.version,
                                    NSNumber(booleanLiteral: latest.isDownloaded))
        
        deleteEntities(Translation.self, matching: predicate)
        
        if saving {
            saveToDisk()
        }
    }
    
    func purgeOlderTranslations(languageId: String, resourceId: String, version: Int16) {
        let lookupPredicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version = %d",
                                          languageId,
                                          resourceId,
                                          version)
        
        guard let translation = findEntity(Translation.self, matching: lookupPredicate) else {
            return
        }
        
        let deletePredicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version < %d AND isDownloaded = %@",
                                          languageId,
                                          resourceId,
                                          version,
                                          NSNumber(booleanLiteral: translation.isDownloaded))
        
        let oldTranslations = findEntities(Translation.self, matching: deletePredicate)
        
        for oldTranslation in oldTranslations {
            deleteEntity(oldTranslation)
        }
    }
}
