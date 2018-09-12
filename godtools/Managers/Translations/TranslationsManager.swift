//
//  TranslationsManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class TranslationsManager: GTDataManager {
    
    func translationWasDownloaded(_ translation: Translation) {
        safelyWriteToRealm {
            translation.isDownloaded = true
        }
    }
    
    func translationsNeedingDownloaded() -> List<Translation> {
        let predicate = NSPredicate(format: "language.shouldDownload = true AND downloadedResource.shouldDownload = true AND isDownloaded = false")

        return findEntities(Translation.self, matching: predicate)
    }
    
    func purgeTranslationsOlderThan(_ latest: Translation) {
        guard let language = latest.language else {
            return
        }
        
        guard let resource = latest.downloadedResource else {
            return
        }
        
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version < %d AND isDownloaded = %@ AND isDownloadInProgress = %@",
                                    language.remoteId,
                                    resource.remoteId,
                                    latest.version,
                                    NSNumber(booleanLiteral: latest.isDownloaded),
                                    NSNumber(booleanLiteral: false))
        
        let recordsToDelete = findEntities(Translation.self, matching: predicate)
        
        safelyWriteToRealm {
            realm.delete(recordsToDelete)
        }
    }
    
    func loadTranslation(resourceCode: String, languageCode: String, published: Bool) -> Translation? {
        let predicate = NSPredicate(format: "language.code = %@ AND downloadedResource.code = %@", languageCode, resourceCode )
        
        return findEntity(Translation.self, matching: predicate)
    }
}
