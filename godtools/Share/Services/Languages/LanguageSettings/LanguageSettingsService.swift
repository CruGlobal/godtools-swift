//
//  LanguageSettingsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsService: NSObject {
    
    private let resourcesCache: RealmResourcesCache
    
    let languageSettingsCache: LanguageSettingsCacheType
    let primaryLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    let parallelLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    
    required init(resourcesCache: RealmResourcesCache, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.resourcesCache = resourcesCache
        self.languageSettingsCache = languageSettingsCache
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        languageSettingsCache.primaryLanguageId.removeObserver(self)
        languageSettingsCache.parallelLanguageId.removeObserver(self)
    }
    
    private func setupBinding() {
        
        languageSettingsCache.primaryLanguageId.addObserver(self) { [weak self] (primaryLanguageId: String?) in
            self?.reloadPrimaryLanguage()
        }
        
        languageSettingsCache.parallelLanguageId.addObserver(self) { [weak self] (parallelLanguageId: String?) in
            self?.reloadParallelLanguage()
        }
    }
    
    private func reloadPrimaryLanguage() {
        resourcesCache.getLanguage(id: languageSettingsCache.primaryLanguageId.value ?? "") { [weak self] (language: LanguageModel?) in
            self?.primaryLanguage.accept(value: language)
        }
    }
    
    private func reloadParallelLanguage() {
        resourcesCache.getLanguage(id: languageSettingsCache.parallelLanguageId.value ?? "") { [weak self] (language: LanguageModel?) in
            self?.parallelLanguage.accept(value: language)
        }
    }
}
