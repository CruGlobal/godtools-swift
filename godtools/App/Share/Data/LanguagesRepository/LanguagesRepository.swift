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

class LanguagesRepository: RepositorySync<LanguageDataModel, MobileContentLanguagesApi> {
    
    private let api: MobileContentLanguagesApi
    
    let cache: LanguagesCache
    
    init(api: MobileContentLanguagesApi, cache: LanguagesCache) {
        
        self.api = api
        self.cache = cache
        
        super.init(
            externalDataFetch: api,
            persistence: cache.getPersistence()
        )
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
