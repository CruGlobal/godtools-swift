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

class TranslationsManager {
    static let shared = TranslationsManager()
    
    var latestTranslations: [Translation]?
    var downloadedTranslations: [Translation]?
    
    func loadLatestTranslationsFromDisk(languageId: String) -> [Translation] {
        if latestTranslations != nil {
            return latestTranslations!
        }
        
        let predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true", languageId)
        latestTranslations = Translation.mr_findAll(with: predicate) as! [Translation]?
        
        return latestTranslations!
    }
    
    func loadDownloadedTranslationsFromDisk(languageId: String) -> [Translation] {
        if downloadedTranslations != nil {
            return downloadedTranslations!
        }
        
        let predicate = NSPredicate(format: "language.remoteId = %@ AND isDownloaded = true", languageId)
        downloadedTranslations = Translation.mr_findAll(with: predicate) as! [Translation]?
        return downloadedTranslations!
    }
    
    func loadTranslationFromRemote(id: String) -> Promise<Translation> {
        return Promise(value: Translation.mr_createEntity()!)
    }
}
