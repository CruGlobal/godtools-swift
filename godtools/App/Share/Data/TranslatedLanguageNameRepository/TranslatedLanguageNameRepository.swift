//
//  TranslatedLanguageNameRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class TranslatedLanguageNameRepository {
    
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let cache: RealmTranslatedLanguageNameCache
    
    init(getTranslatedLanguageName: GetTranslatedLanguageName, cache: RealmTranslatedLanguageNameCache) {
        
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.cache = cache
    }
    
    func getLanguageName(language: BCP47LanguageIdentifier, translatedInLanguage: BCP47LanguageIdentifier) -> String {
        
        if let cachedObject = cache.getTranslatedLanguageName(language: language, languageTranslation: translatedInLanguage) {
            
            let elapsedTimeInSeconds: TimeInterval = Date().timeIntervalSince(cachedObject.updatedAt)
            let elapsedTimeInMinutes: TimeInterval = elapsedTimeInSeconds / 60
            
            if elapsedTimeInMinutes < (60 * 24) {
                return cachedObject.translatedName
            }
        }
        
        let translatedName: String = getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: translatedInLanguage)
        
        cache.storeTranslatedLanguage(
            language: language,
            languageTranslation: translatedInLanguage,
            translatedName: translatedName
        )
                
        return translatedName
    }
}
