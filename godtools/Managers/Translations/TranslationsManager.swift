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
    
    func loadLatestTranslationsFromDisk() -> [Translation] {
        let predicate = NSPredicate(format: "isPublished = true")
        return Translation.mr_findAll(with: predicate) as! [Translation]
    }
    
    func loadDownloadedTranslationsFromDisk() -> [Translation] {
        let predicate = NSPredicate(format: "isDownloaded = true")
        return Translation.mr_findAll(with: predicate) as! [Translation]
    }
    
    func loadTranslationFromRemote(id: String) -> Promise<Translation> {
        return Promise(value: Translation.mr_createEntity()!)
    }
}
