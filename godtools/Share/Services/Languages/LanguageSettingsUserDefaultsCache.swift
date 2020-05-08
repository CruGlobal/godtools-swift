//
//  LanguageSettingsUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsUserDefaultsCache: LanguageSettingsCacheType {
    
    enum LanguageSettingType {
        
        case primary
        case parallel
        
        var key: String {
            switch self {
            case .primary:
                return "kPrimaryLanguageId"
            case .parallel:
                return "kParallelLanguageId"
            }
        }
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    var primaryLanguageId: String? {
        return getLanguageId(setting: .primary)
    }
    
    var parallelLanguageId: String? {
        return getLanguageId(setting: .parallel)
    }
    
    private func getLanguageId(setting: LanguageSettingType) -> String? {
        return defaults.object(forKey: setting.key) as? String
    }
    
    func cachePrimaryLanguageId(language: Language) {
        cacheLanguage(setting: .primary, language: language)
    }

    func cacheParallelLanguageId(language: Language) {
        cacheLanguage(setting: .parallel, language: language)
    }
    
    private func cacheLanguage(setting: LanguageSettingType, language: Language) {
        defaults.set(language.remoteId, forKey: setting.key)
        defaults.synchronize()
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
    }
}
