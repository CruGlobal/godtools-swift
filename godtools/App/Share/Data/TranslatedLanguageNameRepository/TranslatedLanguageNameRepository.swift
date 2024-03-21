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
    
    func getLanguageName(language: TranslatableLanguage, translatedInLanguage: BCP47LanguageIdentifier) -> String {
        
        guard !translatedInLanguage.isEmpty else {
            return language.fallbackName
        }
        
        if let cachedObject = cache.getTranslatedLanguageName(language: language, languageTranslation: translatedInLanguage) {
                        
            return cachedObject.translatedName
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
