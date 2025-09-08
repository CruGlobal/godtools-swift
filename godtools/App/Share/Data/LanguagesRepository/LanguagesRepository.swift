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
    private let cache: RealmLanguagesCache
    
    init(api: MobileContentLanguagesApi, cache: RealmLanguagesCache, realmDatabase: RealmDatabase) {
        
        self.api = api
        self.cache = cache
        
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
    
    func getCachedLanguages(ids: [String]) -> [LanguageDataModel] {
        return getCachedObjects(
            databaseQuery: RepositorySyncDatabaseQuery.filter(
                filter: NSPredicate(format: "\(#keyPath(RealmLanguage.id)) IN %@", ids)
            )
        )
        .map {
            LanguageDataModel(interface: $0)
        }
    }
    
    func syncLanguagesFromRemote(requestPriority: RequestPriority) -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {
        
        return api.getLanguages(requestPriority: requestPriority)
            .flatMap({ languages -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> in
                
                return self.cache.syncLanguages(languages: languages)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func syncLanguagesFromJsonFileCache() -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {
        
        return LanguagesJsonFileCache(jsonServices: JsonServices()).getLanguages().publisher
            .flatMap({ languages -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> in
                
                return self.cache.syncLanguages(languages: languages)
            })
            .eraseToAnyPublisher()
    }
}
