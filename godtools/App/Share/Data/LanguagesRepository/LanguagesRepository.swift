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
    
    func getLanguagesChanged() -> AnyPublisher<Void, Never> {
        return cache.getLanguagesChanged()
    }
    
    func getLanguage(id: String) -> LanguageDataModel? {
        return cache.getLanguage(id: id)
    }
    
    func getLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        return cache.getLanguage(code: code)
    }
    
    func getLanguages(ids: [String]) -> [LanguageDataModel] {
        return cache.getLanguages(ids: ids)
    }
    
    func getLanguages(languageCodes: [BCP47LanguageIdentifier]) -> [LanguageDataModel] {
        return cache.getLanguages(languageCodes: languageCodes)
    }
    
    func getLanguages(realm: Realm? = nil) -> [LanguageDataModel] {
        return cache.getLanguages(realm: realm)
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageDataModel], Never> {
        return cache.getLanguagesPublisher()
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
