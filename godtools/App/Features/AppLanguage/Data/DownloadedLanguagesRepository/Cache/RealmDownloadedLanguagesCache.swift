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

class RealmDownloadedLanguagesCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getDownloadedLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmDownloadedLanguage.self)
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
            .map { DownloadedLanguageDataModel(realmDownloadedLanguage: $0) }
        
        return Just(Array(downloadedLanguages))
            .eraseToAnyPublisher()
    }
    
    func getDownloadedLanguage(languageId: String) -> DownloadedLanguageDataModel? {
        
        guard let downloadedLanguage = realmDatabase.openRealm().object(ofType: RealmDownloadedLanguage.self, forPrimaryKey: languageId) else { return nil }
        
        return DownloadedLanguageDataModel(realmDownloadedLanguage: downloadedLanguage)
    }
    
    func getDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel?, Never> {
        
        return realmDatabase.readObjectPublisher(primaryKey: languageId, mapInBackgroundClosure: { (object: RealmDownloadedLanguage?) in
            guard let realmDownloadedLanguage = object else {
                return nil
            }
            return DownloadedLanguageDataModel(realmDownloadedLanguage: realmDownloadedLanguage)
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
        
        let downloadedLanguage = DownloadedLanguageDataModel(languageId: languageId, downloadComplete: downloadComplete)
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmDownloadedLanguage] in
            
            let realmDownloadedLanguage = RealmDownloadedLanguage()
            realmDownloadedLanguage.mapFrom(dataModel: downloadedLanguage)
            
            return [realmDownloadedLanguage]
            
        } mapInBackgroundClosure: { (objects: [RealmDownloadedLanguage]) -> [DownloadedLanguageDataModel] in
            return objects.map({
                DownloadedLanguageDataModel(realmDownloadedLanguage: $0)
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
}
