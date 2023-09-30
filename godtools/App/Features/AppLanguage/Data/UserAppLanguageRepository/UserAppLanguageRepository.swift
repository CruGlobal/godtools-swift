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
    
    func getLanguagePublisher() -> AnyPublisher<UserAppLanguageDataModel?, Never> {
        
        return cache.getLanguagePublisher()
            .eraseToAnyPublisher()
    }
    
    func getLanguageChangedPublisher() -> AnyPublisher<Void, Never> {
                
        return cache.getLanguageChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func storeLanguagePublisher(languageCode: String) -> AnyPublisher<Bool, Never> {
        
        cache.storeLanguage(languageCode: languageCode)
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
