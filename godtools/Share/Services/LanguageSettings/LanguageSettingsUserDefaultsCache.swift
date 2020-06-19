//
//  LanguageSettingsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsUserDefaultsCache: LanguageSettingsCacheType {
        
    let primaryLanguageId: ObservableValue<String?> = ObservableValue(value: nil)
    let parallelLanguageId: ObservableValue<String?> = ObservableValue(value: nil)
    
    required init() {
                
        primaryLanguageId.accept(value: getLanguageId(setting: .primary))
        parallelLanguageId.accept(value: getLanguageId(setting: .parallel))
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }

    private func getLanguageId(setting: LanguageSettingType) -> String? {
        return defaults.object(forKey: setting.key) as? String
    }
    
    private func getObservable(setting: LanguageSettingType) -> ObservableValue<String?> {
        
        switch setting {
        case .primary:
            return primaryLanguageId
        case .parallel:
            return parallelLanguageId
        }
    }
    
    func cachePrimaryLanguageId(languageId: String) {
        cacheLanguage(setting: .primary, languageId: languageId)
    }

    func cacheParallelLanguageId(languageId: String) {
        cacheLanguage(setting: .parallel, languageId: languageId)
    }
    
    private func cacheLanguage(setting: LanguageSettingType, languageId: String) {
                
        defaults.set(languageId, forKey: setting.key)
        defaults.synchronize()
        getObservable(setting: setting).accept(value: languageId)
    }
    
    func deletePrimaryLanguageId() {
        deleteLanguage(setting: .primary)
    }
    
    func deleteParallelLanguageId() {
        deleteLanguage(setting: .parallel)
    }
    
    private func deleteLanguage(setting: LanguageSettingType) {
        
        defaults.set(nil, forKey: setting.key)
        defaults.synchronize()
        getObservable(setting: setting).accept(value: nil)
    }
}
