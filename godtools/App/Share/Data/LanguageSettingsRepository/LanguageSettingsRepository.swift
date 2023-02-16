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
    
    func getPrimaryLanguageChanged() -> AnyPublisher<Void, Never> {
        return cache.getPrimaryLanguageChanged()
    }
    
    func getParallelLanguageChanged() -> AnyPublisher<String?, Never> {
        return cache.getParallelLanguageChanged()
    }
    
    func getPrimaryLanguageId() -> String? {
        
        return cache.getPrimaryLanguageId()
    }
    
    func getParallelLanguageId() -> String? {
        
        return cache.getParallelLanguageId()
    }

    func storePrimaryLanguage(id: String) {
        
        cache.storePrimaryLanguage(id: id)
    }
    
    func storeParallelLanguage(id: String) {
        
        cache.storeParallelLanguage(id: id)
    }
    
    func deleteParallelLanguage() {
        
        cache.deleteParallelLanguage()
    }
}
