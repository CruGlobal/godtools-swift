//
//  LanguageSettingsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LanguageSettingsCache {
        
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    init() {
        
    }
    
    func getPrimaryLanguageChanged() -> AnyPublisher<Void, Never> {
        return userDefaults.publisher(for: \.primaryLanguageId)
            .flatMap { _ in
                
                return Empty()
            }
            .eraseToAnyPublisher()
    }
    
    func getParallelLanguageChanged() -> AnyPublisher<String?, Never> {
        return userDefaults.publisher(for: \.parallelLanguageId)
            .eraseToAnyPublisher()
    }
    
    func getPrimaryLanguageId() -> String? {
        
        guard let languageId = userDefaults.primaryLanguageId else {
            return nil
        }
        
        return languageId
    }
    
    func getParallelLanguageId() -> String? {
        
        guard let languageId = userDefaults.parallelLanguageId else {
            return nil
        }
        
        return languageId
    }

    func storePrimaryLanguage(id: String?) {
        
        userDefaults.primaryLanguageId = id
    }
    
    func storeParallelLanguage(id: String?) {
        
        userDefaults.parallelLanguageId = id
    }
    
    func deleteParallelLanguage() {
        
        storeParallelLanguage(id: nil)
    }
}

private extension UserDefaults {
    
    private static let primaryLanguageCacheKey: String = "kPrimaryLanguageId"
    private static let parallelLanguageCacheKey: String = "kParallelLanguageId"
    
    @objc dynamic var primaryLanguageId: String? {
                
        get {
            return string(forKey: UserDefaults.primaryLanguageCacheKey)
        }
        set {
            
            set(newValue, forKey: UserDefaults.primaryLanguageCacheKey)
            synchronize()
        }
    }
    
    @objc dynamic var parallelLanguageId: String? {
                
        get {
            return string(forKey: UserDefaults.parallelLanguageCacheKey)
        }
        set {
            
            set(newValue, forKey: UserDefaults.parallelLanguageCacheKey)
            synchronize()
        }
    }
}
