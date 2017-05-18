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
        let context = NSManagedObjectContext.mr_default()
        return Translation.mr_findAll(with: predicate, in: context) as! [Translation]
    }
    
    func purgeTranslationsOlderThan(_ latest: Translation, saving: Bool) {
        let context = NSManagedObjectContext.mr_default()
        
        print(latest)
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@ AND version < %d AND isDownloaded = %@",
                                    latest.language!.remoteId!,
                                    latest.downloadedResource!.remoteId!,
                                    latest.version,
                                    NSNumber(booleanLiteral: latest.isDownloaded))
        
        guard let translationsToPurge: [Translation] = Translation.mr_findAll(with: predicate, in: context) as? [Translation] else {
            return
        }
        
        for translationToPurge in translationsToPurge {
            translationToPurge.mr_deleteEntity(in: context)
        }
        
        if saving {
            saveToDisk()
        }
    }
}
