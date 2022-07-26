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
    
    func getLanguagesChangedPublisher() -> NotificationCenter.Publisher {
        return cache.getLanguagesChangedPublisher()
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
    
    func getLanguages() -> [LanguageModel] {
        return cache.getLanguages()
    }
    
    func downloadAndCacheLanguages() -> AnyPublisher<[LanguageModel], Error> {
        
        return self.api.getLanguages()
            .mapError{
                $0 as Error
            }
            .flatMap({ languages -> AnyPublisher<[LanguageModel], Error> in
                    
                return self.cache.storeLanguages(languages: languages, deletesNonExisting: true)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
