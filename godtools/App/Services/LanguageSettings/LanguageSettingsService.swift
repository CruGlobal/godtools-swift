//
//  LanguageSettingsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: Deprecated in place of LanguageSettingsRepository. ~Levi
class LanguageSettingsService: NSObject {
    
    private let languagesRepository: LanguagesRepository
    
    let languageSettingsCache: LanguageSettingsCacheType
    let primaryLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    let parallelLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    
    required init(languagesRepository: LanguagesRepository, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.languagesRepository = languagesRepository
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
            DispatchQueue.main.async { [weak self] in
                self?.reloadPrimaryLanguage()
            }
        }
        
        languageSettingsCache.parallelLanguageId.addObserver(self) { [weak self] (parallelLanguageId: String?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguage()
            }
        }
    }
    
    private func reloadPrimaryLanguage() {
        let language: LanguageModel? = languagesRepository.getLanguage(id: languageSettingsCache.primaryLanguageId.value ?? "")
        primaryLanguage.accept(value: language)
    }
    
    private func reloadParallelLanguage() {
        let language: LanguageModel? = languagesRepository.getLanguage(id: languageSettingsCache.parallelLanguageId.value ?? "")
        parallelLanguage.accept(value: language)
    }
}
