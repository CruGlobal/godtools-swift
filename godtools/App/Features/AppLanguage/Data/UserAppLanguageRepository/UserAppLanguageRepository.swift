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
        
        return cache.getUserAppLanguagePublisher()
            .eraseToAnyPublisher()
    }
    
    func storeLanguagePublisher(languageCode: String) -> AnyPublisher<Bool, Never> {
        
        cache.storeUserAppLanguage(languageCode: languageCode)
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
