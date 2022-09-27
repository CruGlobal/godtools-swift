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
                
                var existingLanguagesMinusNewlyAddedLanguages: [RealmLanguage] = Array(realm.objects(RealmLanguage.self))
                
                for newLanguage in languages {
                    
                    let realmLanguage: RealmLanguage = RealmLanguage()
                    realmLanguage.mapFrom(model: newLanguage)
                    newLanguagesToStore.append(realmLanguage)
                    
                    if let indexOfNewLanguage = existingLanguagesMinusNewlyAddedLanguages.firstIndex(where: { $0.id == newLanguage.id }) {
                        
                        existingLanguagesMinusNewlyAddedLanguages.remove(at: indexOfNewLanguage)
                    }
                }
                                                
                do {
                    
                    try realm.write {
                        realm.add(newLanguagesToStore, update: .all)
                        realm.delete(existingLanguagesMinusNewlyAddedLanguages)
                    }
                    
                    let result = RealmLanguagesCacheSyncResult(
                        languagesRemoved: existingLanguagesMinusNewlyAddedLanguages.map({LanguageModel(model: $0)})
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
