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
    private let languagesChangedNotificationName = Notification.Name("languagesCache.notification.languagesChanged")

    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLanguagesChangedPublisher() -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: languagesChangedNotificationName)
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
        
    func storeLanguages(languages: [LanguageModel], deletesNonExisting: Bool) -> AnyPublisher<[LanguageModel], Error> {

        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var languagesToRemove: [RealmLanguage] = Array(realm.objects(RealmLanguage.self))
                var writeError: Error?
                
                do {
                    
                    try realm.write {
                        
                        for language in languages {
                            
                            if let index = languagesToRemove.firstIndex(where: {$0.id == language.id}) {
                                languagesToRemove.remove(at: index)
                            }
   
                            if let existingLanguage = realm.object(ofType: RealmLanguage.self, forPrimaryKey: language.id) {
                                
                                existingLanguage.mapFrom(model: language, shouldIgnoreMappingPrimaryKey: true)
                            }
                            else {
                                
                                let newLanguage: RealmLanguage = RealmLanguage()
                                newLanguage.mapFrom(model: language, shouldIgnoreMappingPrimaryKey: false)
                                realm.add(newLanguage)
                            }
                        }
                              
                        if deletesNonExisting {
                            realm.delete(languagesToRemove)
                        }
                        
                        writeError = nil
                    }
                }
                catch let error {
                    
                    writeError = error
                }
                
                if let writeError = writeError {
                    
                    promise(.failure(writeError))
                }
                else {
                                   
                    NotificationCenter.default.post(
                        name: self.languagesChangedNotificationName,
                        object: [languages],
                        userInfo: nil
                    )
                    
                    promise(.success(languages))
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
