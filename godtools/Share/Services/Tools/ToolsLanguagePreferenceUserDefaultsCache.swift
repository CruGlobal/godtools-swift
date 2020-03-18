//
//  ToolsLanguageUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolsLanguagePreferenceUserDefaultsCache: ToolsLanguagePreferenceCacheType {
    
    enum LanguageKey: String {
        case primaryLanguageId = "kPrimaryLanguageId"
        case parallelLanguageId = "kParallelLanguageId"
    }
        
    required init() {
        
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    var primaryLanguageId: String? {
        return getLanguageId(key: .primaryLanguageId)
    }
    
    var parallelLanguageId: String? {
        return getLanguageId(key: .parallelLanguageId)
    }
    
    func cachePrimaryLanguageId(id: String) {
        cacheLanguageId(id: id, key: .primaryLanguageId)
    }
    
    func cacheParallelLanguageId(id: String) {
        cacheLanguageId(id: id, key: .parallelLanguageId)
    }
    
    private func getLanguageId(key: LanguageKey) -> String? {
        return defaults.object(forKey: key.rawValue) as? String
    }
    
    private func cacheLanguageId(id: String, key: LanguageKey) {
        defaults.set(id, forKey: key.rawValue)
        defaults.synchronize()
    }
}
