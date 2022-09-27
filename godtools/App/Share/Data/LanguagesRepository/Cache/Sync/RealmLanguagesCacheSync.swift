//
//  RealmLanguagesCacheSync.swift
//  godtools
//
//  Created by Levi Eggert on 9/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmLanguagesCacheSync {
    
    private let realmDatabase: RealmDatabase

    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func syncLanguages(languages: [LanguageModel]) -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {

        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var newLanguagesToStore: [Object] = Array()
                var existingLanguagesMinusNewlyAddedLanguages: [String] = Array(realm.objects(RealmLanguage.self)).map({$0.id})
                
                for newLanguage in languages {
                    
                    let realmLanguage: RealmLanguage = RealmLanguage()
                    realmLanguage.mapFrom(model: newLanguage)
                    newLanguagesToStore.append(realmLanguage)
                    
                    if let indexOfNewLanguage = existingLanguagesMinusNewlyAddedLanguages.firstIndex(of: newLanguage.id) {
                        existingLanguagesMinusNewlyAddedLanguages.remove(at: indexOfNewLanguage)
                    }
                }
                
                let languagesToRemove: [RealmLanguage] = Array(realm.objects(RealmLanguage.self).filter("id IN %@", existingLanguagesMinusNewlyAddedLanguages))
                                
                do {
                    
                    try realm.write {
                        realm.add(newLanguagesToStore, update: .all)
                        realm.delete(languagesToRemove)
                    }
                    
                    let result = RealmLanguagesCacheSyncResult(
                        languageIdsRemoved: existingLanguagesMinusNewlyAddedLanguages
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
}
