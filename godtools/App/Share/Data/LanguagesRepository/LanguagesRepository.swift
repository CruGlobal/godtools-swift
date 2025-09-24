//
//  LanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift
import RequestOperation
import SwiftData

class LanguagesRepository: RepositorySync<LanguageDataModel, MobileContentLanguagesApi, RealmDatabaseQuery> {
    
    private let api: MobileContentLanguagesApi
    
    init(api: MobileContentLanguagesApi, realmDatabase: RealmDatabase) {
        
        self.api = api
        
        let persistence = RealmRepositorySyncPersistence(
            realmDatabase: realmDatabase,
            dataModelMapping: LanguagesDataModelMapping()
        )
        
        super.init(
            externalDataFetch: api,
            persistence: persistence
        )
    }
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
        
        return persistence.getObjects(query: RealmDatabaseQuery.filter(filter: filter)).first
    }
    
    func getCachedLanguages(languageCodes: [String]) -> [LanguageDataModel] {
        return languageCodes.compactMap({ getCachedLanguage(code: $0) })
    }
    
    func syncLanguagesFromRemote(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> {
        
        return api.getObjectsPublisher(
            requestPriority: requestPriority
        )
        .flatMap { (getObectsResponse: RepositorySyncResponse<LanguageCodable>) in
            
            let response: RepositorySyncResponse<LanguageDataModel> = super.storeExternalObjectsToPersistence(
                externalObjects: getObectsResponse.objects,
                deleteObjectsNotFoundInExternalObjects: true
            )
            
            return Just(response)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func syncLanguagesFromJsonFileCache() -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> {
        
        return LanguagesJsonFileCache(
            jsonServices: JsonServices()
        )
        .getLanguages()
        .publisher
        .flatMap { (languages: [LanguageCodable]) -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> in
            
            let response: RepositorySyncResponse<LanguageDataModel> = super.storeExternalObjectsToPersistence(
                externalObjects: languages,
                deleteObjectsNotFoundInExternalObjects: false
            )
                    
            return Just(response)
                .eraseToAnyPublisher()
        }
        .catch { (error: Error) in
            
            let response = RepositorySyncResponse<LanguageDataModel>(
                objects: [],
                errors: [error]
            )
            
            return Just(response)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
