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
    
    func storeDownloadedLanguage(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel, Error> {
        
        let downloadedLanguage = DownloadedLanguageDataModel(languageId: languageId)
        
        return realmDatabase.writeObjectsPublisher { realm in
            
            let realmDownloadedLanguage = RealmDownloadedLanguage()
            realmDownloadedLanguage.mapFrom(dataModel: downloadedLanguage)
            
            return [realmDownloadedLanguage]
        }
        .map { _ in
            
            return downloadedLanguage
        }
        .eraseToAnyPublisher()
        
    }
    
    func deleteDownloadedLanguage(languageId: String) -> AnyPublisher<Void, Error> {
        
        return realmDatabase.readObjectPublisher(primaryKey: languageId)
            .flatMap { (object: RealmDownloadedLanguage?) -> AnyPublisher<Void, Error> in
                
                guard let object = object else {
                    return Just(Void())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.realmDatabase.deleteObjectsPublisher(objects: [object])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
