//
//  ToolsLanguageUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolsLanguagePreferenceUserDefaultsCache: ToolsLanguagePreferenceCacheType {
    
    required init() {
        
    }
    
    private var keyPrimaryLanguageId: String {
        return "kPrimaryLanguageId"
    }
    private var keyParallelLanguageId: String {
        return "kParallelLanguageId"
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    var primaryLanguageId: String? {
        return defaults.object(forKey: keyPrimaryLanguageId) as? String
    }
    
    var parallelLanguageId: String? {
        return defaults.object(forKey: keyParallelLanguageId) as? String
    }
    
    func cachePrimaryLanguageId(language: Language) {
        defaults.set(language.remoteId, forKey: keyPrimaryLanguageId)
        defaults.synchronize()
    }

    func cacheParallelLanguageId(language: Language) {
        defaults.set(language.remoteId, forKey: keyParallelLanguageId)
        defaults.synchronize()
    }
    
    func deletePrimaryLanguageId() {
        defaults.set(nil, forKey: keyPrimaryLanguageId)
        defaults.synchronize()
    }
    
    func deleteParallelLanguageId() {
        defaults.set(nil, forKey: keyParallelLanguageId)
        defaults.synchronize()
    }
}
