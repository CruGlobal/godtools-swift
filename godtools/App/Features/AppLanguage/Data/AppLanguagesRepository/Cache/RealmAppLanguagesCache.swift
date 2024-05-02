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
    
    func getNumberOfLanguages() -> Int {
        return realmDatabase.openRealm()
            .objects(RealmAppLanguage.self)
            .count
    }
    
    func getLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        return realmDatabase.openRealm()
            .objects(RealmAppLanguage.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        return realmDatabase.readObjectsPublisher()
            .flatMap({ (results: Results<RealmAppLanguage>) -> AnyPublisher<[AppLanguageDataModel], Never> in
                
                let objects: [AppLanguageDataModel] = results.map({
                    AppLanguageDataModel(realmAppLanguage: $0)
                })
                
                return Just(objects)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<AppLanguageDataModel?, Never> {
        
        return realmDatabase.readObjectPublisher(primaryKey: languageId)
            .map { (realmAppLanguage: RealmAppLanguage?) in
                
                guard let realmAppLanguage = realmAppLanguage else {
                    return nil
                }
                
                return AppLanguageDataModel(realmAppLanguage: realmAppLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    func storeLanguagesPublisher(appLanguages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let realmObjects: [RealmAppLanguage] = appLanguages.map({
                let realmAppLanguage = RealmAppLanguage()
                realmAppLanguage.mapFrom(dataModel: $0)
                return realmAppLanguage
            })
            
            return realmObjects
        }
        .map { _ in
            return appLanguages
        }
        .eraseToAnyPublisher()
    }
}
