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
    
    var primaryLanguageId: String? {
        return getLanguageId(key: .primaryLanguageId)
    }
    
    var parallelLanguageId: String? {
        return getLanguageId(key: .parallelLanguageId)
    }
    
    func cachePrimaryLanguageId(id: String) {
        cacheLanguageId(id: id, key: .primaryLanguageId)
    }
    
    func deletePrimaryLanguageId() {
        deleteLanguageId(key: .primaryLanguageId)
    }

    func cacheParallelLanguageId(id: String) {
        cacheLanguageId(id: id, key: .parallelLanguageId)
    }
    
    func deleteParallelLanguageId() {
        deleteLanguageId(key: .parallelLanguageId)
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func getLanguageId(key: LanguageKey) -> String? {
        return defaults.object(forKey: key.rawValue) as? String
    }
    
    private func cacheLanguageId(id: String, key: LanguageKey) {
        defaults.set(id, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    private func deleteLanguageId(key: LanguageKey) {
        defaults.set(nil, forKey: key.rawValue)
        defaults.synchronize()
    }
}
