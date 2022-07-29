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
    
    func getLanguagesSyncedPublisher() -> NotificationCenter.Publisher {
        return cache.getLanguagesSyncedPublisher()
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
    
    func syncLanguagesFromRemote() -> AnyPublisher<RealmLanguagesCacheSyncResult, URLResponseError> {
        
        return api.getLanguages()
            .flatMap({ languages -> AnyPublisher<RealmLanguagesCacheSyncResult, URLResponseError> in
                
                return self.cache.syncLanguages(languages: languages)
                    .mapError { error in
                        return .otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func syncLanguagesFromJsonFileCache() -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {
        
        return LanguagesJsonFileCache().getLanguages().publisher
            .flatMap({ languages -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> in
                
                return self.cache.syncLanguages(languages: languages)
            })
            .eraseToAnyPublisher()
    }
}
