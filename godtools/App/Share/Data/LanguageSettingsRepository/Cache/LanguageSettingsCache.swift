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
    
    private let primaryLanguageChangedNotificationName = Notification.Name("languageSettingsCache.notification.primaryLanguageChanged")
    private let parallelLanguageChangedNotificationName = Notification.Name("languageSettingsCache.notification.parallelLanguageChanged")
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let languagesRepository: LanguagesRepository
    
    init(languagesRepository: LanguagesRepository) {
        
        self.languagesRepository = languagesRepository
    }
    
    func getPrimaryLanguageChangedPublisher() -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: primaryLanguageChangedNotificationName)
    }
    
    func getParallelLanguageChangedPublisher() -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: parallelLanguageChangedNotificationName)
    }
    
    func getPrimaryLanguage() -> LanguageModel? {
        
        guard let languageId = userDefaults.primaryLanguageId else {
            return nil
        }
        
        return languagesRepository.getLanguage(id: languageId)
    }
    
    func getParallelLanguage() -> LanguageModel? {
        
        guard let languageId = userDefaults.parallelLanguageId else {
            return nil
        }
        
        return languagesRepository.getLanguage(id: languageId)
    }

    func storePrimaryLanguage(language: LanguageModel) {
        
        userDefaults.primaryLanguageId = language.id
        
        NotificationCenter.default.post(
            name: self.primaryLanguageChangedNotificationName,
            object: language,
            userInfo: nil
        )
    }
    
    func storeParallelLanguage(language: LanguageModel) {
        
        userDefaults.parallelLanguageId = language.id
        
        NotificationCenter.default.post(
            name: self.parallelLanguageChangedNotificationName,
            object: language,
            userInfo: nil
        )
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
