//
//  LanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import RepositorySync
import Combine

class LanguagesRepository: RepositorySync<LanguageDataModel, MobileContentLanguagesApi> {
    
    let cache: LanguagesCache
    
    init(externalDataFetch: MobileContentLanguagesApi, persistence: any Persistence<LanguageDataModel, LanguageCodable>, cache: LanguagesCache) {
        
        self.cache = cache
        
        super.init(externalDataFetch: externalDataFetch, persistence: persistence)
    }
}

// MARK: - Sync

extension LanguagesRepository {
    
    func syncLanguagesFromRemote(requestPriority: RequestPriority) -> AnyPublisher<[LanguageDataModel], Error> {
        
        return externalDataFetch.getObjectsPublisher(
            context: RequestOperationFetchContext(requestPriority: requestPriority)
        )
        .flatMap { (languages: [LanguageCodable]) in
            
            return super.persistence.writeObjectsPublisher(
                externalObjects: languages,
                writeOption: .deleteObjectsNotInExternal,
                getOption: .allObjects
            )
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func syncLanguagesFromJsonFileCache() -> AnyPublisher<[LanguageDataModel], Error> {
        
        return LanguagesJsonFileCache(
            jsonServices: JsonServices()
        )
        .getLanguages()
        .publisher
        .flatMap { (languages: [LanguageCodable]) -> AnyPublisher<[LanguageDataModel], Error> in
            
            return super.persistence.writeObjectsPublisher(
                externalObjects: languages,
                writeOption: nil,
                getOption: .allObjects
            )
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
