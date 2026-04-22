//
//  RealmDownloadedLanguagesCache.swift
//  godtools
//
//  Created by Rachael Skeath on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

final class RealmDownloadedLanguagesCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    @MainActor func getDownloadedLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmDownloadedLanguage.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getDownloadedLanguagesPublisher(completedDownloadsOnly: Bool) -> AnyPublisher<[DownloadedLanguageDataModel], Never> {
        
        var realmDownloadedLanguages = realmDatabase.openRealm()
            .objects(RealmDownloadedLanguage.self)
        
        if completedDownloadsOnly {
            realmDownloadedLanguages = realmDownloadedLanguages
                .where { $0.downloadComplete }
        }
        
        let downloadedLanguages = realmDownloadedLanguages
            .map { $0.toModel() }
        
        return Just(Array(downloadedLanguages))
            .eraseToAnyPublisher()
    }
    
    func getDownloadedLanguage(languageId: String) -> DownloadedLanguageDataModel? {
        
        guard let downloadedLanguage = realmDatabase.openRealm()
            .object(ofType: RealmDownloadedLanguage.self, forPrimaryKey: languageId) else {
            
            return nil
        }
        
        return downloadedLanguage.toModel()
    }
    
    func getDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel?, Never> {
        
        return realmDatabase.readObjectPublisher(primaryKey: languageId, mapInBackgroundClosure: { (object: RealmDownloadedLanguage?) in
            guard let realmDownloadedLanguage = object else {
                return nil
            }
            return realmDownloadedLanguage.toModel()
        })
        .flatMap { (dataModel: DownloadedLanguageDataModel?) in

            return Just(dataModel)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func storeDownloadedLanguage(languageId: String, downloadComplete: Bool) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmDownloadedLanguage = RealmDownloadedLanguage()
        realmDownloadedLanguage.languageId = languageId
        realmDownloadedLanguage.downloadComplete = downloadComplete
        
        do {
            
            try realm.write {
                realm.add(realmDownloadedLanguage, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func storeDownloadedLanguagePublisher(languageId: String, downloadComplete: Bool) -> AnyPublisher<DownloadedLanguageDataModel, Error> {
        
        let downloadedLanguage = DownloadedLanguageDataModel(
            id: languageId,
            createdAt: Date(),
            languageId: languageId,
            downloadComplete: downloadComplete
        )
                
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmDownloadedLanguage] in
            
            let realmDownloadedLanguage = RealmDownloadedLanguage.createNewFrom(model: downloadedLanguage)
            
            return [realmDownloadedLanguage]
            
        } mapInBackgroundClosure: { (objects: [RealmDownloadedLanguage]) -> [DownloadedLanguageDataModel] in
            return objects.map({
                $0.toModel()
            })
        }
        .map { _ in
            return downloadedLanguage
        }
        .eraseToAnyPublisher()
        
    }
    
    func deleteDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<Void, Error> {
        
        return realmDatabase.deleteObjectsInBackgroundPublisher(
            type: RealmDownloadedLanguage.self,
            primaryKeyPath: #keyPath(RealmDownloadedLanguage.languageId),
            primaryKeys: [languageId]
        )
        .eraseToAnyPublisher()
    }
    
    func markAllDownloadsAsCompleted() {
            
        let realm: Realm = realmDatabase.openRealm()
        
        let nonCompletedDownloads = realm
            .objects(RealmDownloadedLanguage.self)
            .where { $0.downloadComplete == false }
        
        _ = realmDatabase.writeObjects(realm: realm, updatePolicy: .modified) { realm in
            
            for language in nonCompletedDownloads {
                language.downloadComplete = true
            }
            
            return Array(nonCompletedDownloads)
        }
    }
}
