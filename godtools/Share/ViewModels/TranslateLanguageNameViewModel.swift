//
//  TranslateLanguageNameViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslateLanguageNameViewModel {

    private let localizationServices: LocalizationServices
    
    let languageSettingsService: LanguageSettingsService
    let shouldFallbackToPrimaryLanguageLocale: Bool
    
    required init(languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, shouldFallbackToPrimaryLanguageLocale: Bool) {
        
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.shouldFallbackToPrimaryLanguageLocale = shouldFallbackToPrimaryLanguageLocale
    }
    
    func getLocalizedLanguageNameForLanguage(language: LanguageModelType, localizedBundle: Bundle) -> String? {
        
        let key: String = "language_name_" + language.code
        let localizedName: String = localizationServices.stringForBundle(bundle: localizedBundle, key: key)
        
        if !localizedName.isEmpty && localizedName != key {
            return localizedName
        }
        
        return nil
    }
    
    func getTranslatedName(language: LanguageModelType) -> String {
        
        if let localizedName = getLocalizedLanguageNameForLanguage(language: language, localizedBundle: Bundle.main) {
            
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
