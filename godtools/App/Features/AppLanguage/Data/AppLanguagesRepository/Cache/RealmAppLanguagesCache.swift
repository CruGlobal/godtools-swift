//
//  RealmAppLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class RealmAppLanguagesCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func observeChangesPublisher() -> AnyPublisher<Void, Never> {
        return realmDatabase.openRealm().objects(RealmAppLanguage.self).objectWillChange
            .eraseToAnyPublisher()
            .prepend(Void())
            .eraseToAnyPublisher()
    }

    func getNumberOfLanguagesPublisher() -> AnyPublisher<Int, Never> {
        
        let count: Int = realmDatabase.openRealm()
            .objects(RealmAppLanguage.self)
            .count
        
        return Just(count)
            .eraseToAnyPublisher()
    }
        
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        
        return realmDatabase.readObjectsPublisher(mapInBackgroundClosure: { (results: Results<RealmAppLanguage>) -> [AppLanguageDataModel] in
            
            return results.map({
                AppLanguageDataModel(dataModel: $0)
            })
        })
        .eraseToAnyPublisher()
    }
    
    func getLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<AppLanguageDataModel?, Never> {
        
        return realmDatabase.readObjectPublisher(primaryKey: languageId, mapInBackgroundClosure: { (object: RealmAppLanguage?) -> AppLanguageDataModel? in
            
            guard let realmAppLanguage = object else {
                return nil
            }
            
            return AppLanguageDataModel(dataModel: realmAppLanguage)
        })
        .eraseToAnyPublisher()
    }
    
    func storeLanguagesPublisher(appLanguages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmAppLanguage] in
            
            let realmObjects: [RealmAppLanguage] = appLanguages.map({
                let realmAppLanguage = RealmAppLanguage()
                realmAppLanguage.mapFrom(dataModel: $0)
                return realmAppLanguage
            })
            
            return realmObjects
            
        } mapInBackgroundClosure: { (objects: [RealmAppLanguage]) -> [AppLanguageDataModel] in
            
            return objects.map({
                AppLanguageDataModel(dataModel: $0)
            })
        }
        .eraseToAnyPublisher()
    }
}
