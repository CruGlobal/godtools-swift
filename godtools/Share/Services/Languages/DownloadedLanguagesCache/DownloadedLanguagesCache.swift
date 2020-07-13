//
//  DownloadedLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class DownloadedLanguagesCache {
    
    typealias LanguageId = String
    
    private let realmDatabase: RealmDatabase
    
    let languageDownloaded: SignalValue<LanguageId> = SignalValue()
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getDownloadedLanguages() -> [DownloadedLanguageModel] {
        return getDownloadedLanguages(realm: realmDatabase.mainThreadRealm)
    }
    
    func getDownloadedLanguages(realm: Realm) -> [DownloadedLanguageModel] {
        let realmDownloadedLanguages: [RealmDownloadedLanguage] = Array(realm.objects(RealmDownloadedLanguage.self))
        return realmDownloadedLanguages.map({DownloadedLanguageModel(model: $0)})
    }
    
    func isDownloaded(languageId: String) -> Bool {
        return isDownloaded(realm: realmDatabase.mainThreadRealm, languageId: languageId)
    }
    
    func isDownloaded(realm: Realm, languageId: String) -> Bool {
        return realm.object(ofType: RealmDownloadedLanguage.self, forPrimaryKey: languageId) != nil
    }
    
    func addDownloadedLanguage(languageId: String) {
        addDownloadedLanguage(realm: realmDatabase.mainThreadRealm, languageId: languageId)
    }
    
    func addDownloadedLanguage(realm: Realm, languageId: String) {
        
        if realm.object(ofType: RealmDownloadedLanguage.self, forPrimaryKey: languageId) != nil {
            return
        }
                
        let downloadedLanguage = RealmDownloadedLanguage()
        downloadedLanguage.languageId = languageId
        
        do {
            try realm.write {
                realm.add(downloadedLanguage, update: .all)
            }
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return
        }
        
        languageDownloaded.accept(value: languageId)
    }
    
    func bulkDeleteDownloadedLanguages(realm: Realm, languageIds: [String]) -> Error? {
        
        var downloadedLanguagesToDelete: [RealmDownloadedLanguage] = Array()
        
        for languageId in languageIds {
            if let realmDownloadedLanguage = realm.object(ofType: RealmDownloadedLanguage.self, forPrimaryKey: languageId) {
                downloadedLanguagesToDelete.append(realmDownloadedLanguage)
            }
        }
        
        guard !downloadedLanguagesToDelete.isEmpty else {
            return nil
        }
        
        do {
            try realm.write {
                realm.delete(downloadedLanguagesToDelete)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
}
