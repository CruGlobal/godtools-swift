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
import RealmSwift

class TranslationsManager: GTDataManager {
    static let shared = TranslationsManager()
    
    func translationWasDownloaded(_ translation: Translation) {
        translation.isDownloaded = true
        saveToDisk()
    }
    
    func translationsNeedingDownloaded() -> List<Translation> {
        let predicate = NSPredicate(format: "language.shouldDownload = true AND downloadedResource.shouldDownload = true AND isDownloaded = false")

        return findEntities(Translation.self, matching: predicate)
    }
    
    func purgeTranslationsOlderThan(_ latest: Translation, saving: Bool) {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version < %d AND isDownloaded = %@",
                                    latest.language.first!.remoteId,
                                    latest.downloadedResource.first!.remoteId,
                                    latest.version,
                                    NSNumber(booleanLiteral: latest.isDownloaded))
        
        deleteEntities(Translation.self, matching: predicate)
        
        if saving {
            saveToDisk()
        }
    }
}
