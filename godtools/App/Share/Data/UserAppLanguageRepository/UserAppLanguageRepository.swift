//
//  UserAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class UserAppLanguageRepository {
        
    private let cache: RealmUserAppLanguageCache
    
    init(cache: RealmUserAppLanguageCache) {
        
        self.cache = cache
    }
    
    func getUserAppLanguage() -> UserAppLanguageDataModel? {
        
        return cache.getUserAppLanguage()
    }
    
    func storeUserAppLanguage(languageCode: String) {
        
        cache.storeUserAppLanguage(languageCode: languageCode)
    }
}
