//
//  RealmLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmLanguagesCache {
    
    private let realmDatabase: RealmDatabase
    private let languagesSyncedNotificationName = Notification.Name("languagesCache.notification.languagesSynced")

    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    var numberOfLanguages: Int {
        return realmDatabase.mainThreadRealm.objects(RealmLanguage.self).count
    }
    
    func getLanguagesSyncedPublisher() -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: languagesSyncedNotificationName)
    }
    
    func getLanguage(id: String) -> LanguageModel? {
        
        guard let realmLanguage = realmDatabase.mainThreadRealm.object(ofType: RealmLanguage.self, forPrimaryKey: id) else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
    
    func getLanguage(code: String) -> LanguageModel? {
                
        guard let realmLanguage = realmDatabase.mainThreadRealm.objects(RealmLanguage.self).filter(NSPredicate(format: "code".appending(" = [c] %@"), code.lowercased())).first else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
    
    func getLanguages(ids: [String]) -> [LanguageModel] {
        
        return realmDatabase.mainThreadRealm.objects(RealmLanguage.self)
            .filter("id IN %@", ids)
            .map{
                LanguageModel(model: $0)
            }
    }
    
    func getLanguages() -> [LanguageModel] {
        return realmDatabase.mainThreadRealm.objects(RealmLanguage.self)
            .map({LanguageModel(model: $0)})
    }
        
    func syncLanguages(languages: [LanguageModel]) -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {

        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var languagesToStore: [Object] = Array()
                var languagesStored: [String: RealmLanguage] = Dictionary()
                var languageIdsRemoved: [String] = Array(realm.objects(RealmLanguage.self)).map({$0.id})
                
                for language in languages {
                    
                    let realmLanguage: RealmLanguage = RealmLanguage()
                    realmLanguage.mapFrom(model: language)
                    languagesToStore.append(realmLanguage)
                    languagesStored[realmLanguage.id] = realmLanguage
                    
                    if let index = languageIdsRemoved.firstIndex(of: language.id) {
                        languageIdsRemoved.remove(at: index)
                    }
                }
                
                let languagesToRemove: [RealmLanguage] = Array(realm.objects(RealmLanguage.self).filter("id IN %@", languageIdsRemoved))
                                
                do {
                    
                    try realm.write {
                        realm.add(languagesToStore, update: .all)
                        realm.delete(languagesToRemove)
                    }
                    
                    NotificationCenter.default.post(
                        name: self.languagesSyncedNotificationName,
                        object: [languages],
                        userInfo: nil
                    )
                    
                    let result = RealmLanguagesCacheSyncResult(
                        languagesStored: languagesStored,
                        languageIdsRemoved: languageIdsRemoved
                    )
                    
                    promise(.success(result))
                }
                catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: -
    
    // TODO: Remove deprecated methods. ~Levi
    
    @available(*, deprecated)
    func getLanguage(realm: Realm, id: String) -> RealmLanguage? {
        return realm.object(ofType: RealmLanguage.self, forPrimaryKey: id)
    }

    @available(*, deprecated)
    func getLanguage(realm: Realm, code: String) -> RealmLanguage? {

        guard !code.isEmpty else {
            return nil
        }

        let lowercasedCode: String = code.lowercased()

        return realm.objects(RealmLanguage.self).filter(NSPredicate(format: "code".appending(" = [c] %@"), lowercasedCode)).first
    }
}
