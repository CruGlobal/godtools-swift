//
//  TranslateLanguageNameViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslateLanguageNameViewModel {

    let languageSettingsService: LanguageSettingsService
    let shouldFallbackToPrimaryLanguageLocale: Bool
    
    required init(languageSettingsService: LanguageSettingsService, shouldFallbackToPrimaryLanguageLocale: Bool) {
        
        self.languageSettingsService = languageSettingsService
        self.shouldFallbackToPrimaryLanguageLocale = shouldFallbackToPrimaryLanguageLocale
    }
    
    func getTranslatedName(language: LanguageModelType) -> String {
        
        let localizedNameKey: String = "language_name_" + language.code
        let localizedName: String = NSLocalizedString(localizedNameKey, comment: "")
                
        if !localizedName.isEmpty && localizedName != localizedNameKey {
            
            return localizedName
        }
        
        let locale: Locale
        
        if shouldFallbackToPrimaryLanguageLocale, let primaryLanguage = languageSettingsService.primaryLanguage.value {
            locale = Locale(identifier: primaryLanguage.code)
        }
        else {
            locale = Locale.current
        }
        
        if let localeName = locale.localizedString(forIdentifier: language.code), !localeName.isEmpty {
            return localeName
        }
        
        return language.name
    }
}
