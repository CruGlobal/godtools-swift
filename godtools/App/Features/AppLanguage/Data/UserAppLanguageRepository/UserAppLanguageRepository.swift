//
//  UserAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class UserAppLanguageRepository {
        
    private let cache: RealmUserAppLanguageCache
    
    init(cache: RealmUserAppLanguageCache) {
        
        self.cache = cache
    }
    
    func getCachedLanguage() -> UserAppLanguageDataModel? {
        return cache.getLanguage()
    }
    
    func getLanguagePublisher() -> AnyPublisher<UserAppLanguageDataModel?, Never> {
        
        return cache.getLanguagePublisher()
            .eraseToAnyPublisher()
    }
    
    func getLanguageChangedPublisher() -> AnyPublisher<Void, Never> {
                
        return cache.getLanguageChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func storeLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<UserAppLanguageDataModel?, Error> {
        
        return cache.storeLanguagePublisher(languageId: languageId)
            .eraseToAnyPublisher()
    }
}
