//
//  RealmTranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmTranslationsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }

    func getTranslation(id: String) -> TranslationModel? {
        
        guard let realmTranslation = realmDatabase.mainThreadRealm.object(ofType: RealmTranslation.self, forPrimaryKey: id) else {
            return nil
        }
        
        return TranslationModel(realmTranslation: realmTranslation)
    }
    
    func getTranslations(ids: [String]) -> [TranslationModel] {
        
        return realmDatabase.mainThreadRealm.objects(RealmTranslation.self)
            .filter("id IN %@", ids)
            .map{
                TranslationModel(realmTranslation: $0)
            }
    }
    
    func storeTranslations(translations: [TranslationModel], deletesNonExisting: Bool) -> AnyPublisher<[TranslationModel], Error> {
        
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var translationsToRemove: [RealmTranslation] = Array(realm.objects(RealmTranslation.self))
                var writeError: Error?
                
                do {
                    
                    try realm.write {
                        
                        for translation in translations {
                            
                            if let index = translationsToRemove.firstIndex(where: {$0.id == translation.id}) {
                                translationsToRemove.remove(at: index)
                            }
   
                            if let existingTranslation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translation.id) {
                                
                                existingTranslation.mapFrom(model: translation, shouldIgnoreMappingPrimaryKey: true)
                            }
                            else {
                                
                                let newTranslation: RealmTranslation = RealmTranslation()
                                newTranslation.mapFrom(model: translation, shouldIgnoreMappingPrimaryKey: false)
                                realm.add(newTranslation)
                            }
                        }
                                   
                        if deletesNonExisting {
                            realm.delete(translationsToRemove)
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
                    
                    promise(.success(translations))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
