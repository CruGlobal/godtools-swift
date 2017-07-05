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
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version < %d AND isDownloaded = %@",
                                    latest.language!.remoteId,
                                    latest.downloadedResource!.remoteId,
                                    latest.version,
                                    NSNumber(booleanLiteral: latest.isDownloaded))
        
        if realm.isInWriteTransaction {
            realm.delete(findEntities(Translation.self, matching: predicate))
        } else {
            safelyWriteToRealm {
                realm.delete(findEntities(Translation.self, matching: predicate))
            }
        }
    }
    
    func loadTranslation(resourceCode: String, languageCode: String, published: Bool) -> Translation? {
        let predicate = NSPredicate(format: "language.code = %@ AND downloadedResource.code = %@", languageCode, resourceCode )
        
        return findEntity(Translation.self, matching: predicate)
    }
}
