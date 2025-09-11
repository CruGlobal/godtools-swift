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

class LanguagesRepository: RepositorySync<LanguageDataModel, MobileContentLanguagesApi, RealmLanguage> {
    
    private let api: MobileContentLanguagesApi
    
    init(api: MobileContentLanguagesApi, realmDatabase: RealmDatabase) {
        
        self.api = api
        
        super.init(
            externalDataFetch: api,
            realmDatabase: realmDatabase,
            dataModelMapping: LanguagesDataModelMapping()
        )
    }
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        return getCachedObjects(
            databaseQuery: RepositorySyncDatabaseQuery.filter(
                filter: NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
            )
        ).first
    }
    
    func getCachedLanguages(languageCodes: [String]) -> [LanguageDataModel] {
        return languageCodes.compactMap({ getCachedLanguage(code: $0) })
    }
    
    func syncLanguagesFromRemote(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> {
        
        return api.getObjectsPublisher(
            requestPriority: requestPriority
        )
        .flatMap { (getObectsResponse: RepositorySyncResponse<LanguageCodable>) in
            
            let response: RepositorySyncResponse<LanguageDataModel> = super.syncExternalDataFetchResponse(
                response: getObectsResponse
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
            
            let response: RepositorySyncResponse<LanguageDataModel> = super.storeExternalDataFetchResponse(
                response: RepositorySyncResponse<LanguageCodable>(objects: languages, errors: [])
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
