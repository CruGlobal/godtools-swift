//
//  LanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LanguagesRepository {
    
    private let api: MobileContentLanguagesApi
    private let cache: RealmLanguagesCache
    
    required init(api: MobileContentLanguagesApi, cache: RealmLanguagesCache) {
        
        self.api = api
        self.cache = cache
    }
    
    var numberOfLanguages: Int {
        return cache.numberOfLanguages
    }

    func getLanguagesChanged() -> AnyPublisher<Void, Never> {
        return cache.getLanguagesChanged()
    }
    
    func getLanguage(id: String) -> LanguageModel? {
        return cache.getLanguage(id: id)
    }
    
    func getLanguage(code: String) -> LanguageModel? {
        return cache.getLanguage(code: code)
    }
    
    func getLanguages(ids: [String]) -> [LanguageModel] {
        return cache.getLanguages(ids: ids)
    }
    
    func getLanguages(languageCodes: [String]) -> [LanguageModel] {
        return cache.getLanguages(languageCodes: languageCodes)
    }
    
    func getLanguages() -> [LanguageModel] {
        return cache.getLanguages()
    }
    
    func syncLanguagesFromRemote() -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {
        
        return api.getLanguages()
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
