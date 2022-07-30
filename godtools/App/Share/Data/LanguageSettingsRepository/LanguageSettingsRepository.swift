//
//  LanguageSettingsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LanguageSettingsRepository {
    
    private let cache: LanguageSettingsCache
    
    init(cache: LanguageSettingsCache) {
        
        self.cache = cache
    }
    
    func getPrimaryLanguageChangedPublisher() -> NotificationCenter.Publisher {
        
        return cache.getPrimaryLanguageChangedPublisher()
    }
    
    func getParallelLanguageChangedPublisher() -> NotificationCenter.Publisher {
        
        return cache.getParallelLanguageChangedPublisher()
    }
    
    func getPrimaryLanguage() -> LanguageModel? {
        
        return cache.getPrimaryLanguage()
    }
    
    func getParallelLanguage() -> LanguageModel? {
        
        return cache.getParallelLanguage()
    }

    func storePrimaryLanguage(language: LanguageModel) {
        
        cache.storePrimaryLanguage(language: language)
    }
    
    func storeParallelLanguage(language: LanguageModel) {
        
        cache.storeParallelLanguage(language: language)
    }
}
