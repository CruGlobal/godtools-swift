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
    
    func loadLatestTranslationsFromDisk(languageId: String) -> [Translation] {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND isPublished = true", languageId)
        return Translation.mr_findAll(with: predicate) as! [Translation]
    }
    
    func loadDownloadedTranslationsFromDisk(languageId: String) -> [Translation] {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND isDownloaded = true", languageId)
        return Translation.mr_findAll(with: predicate) as! [Translation]
    }
    
    func loadTranslationFromRemote(id: String) -> Promise<Translation> {
        return Promise(value: Translation.mr_createEntity()!)
    }
}
