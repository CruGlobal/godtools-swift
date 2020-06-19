//
//  LanguageNameTranslationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct LanguageNameTranslationViewModel {

    let name: String
    
    init(language: LanguageModelType, languageSettingsService: LanguageSettingsService, shouldFallbackToPrimaryLanguageLocale: Bool) {
                
        let localizedNameKey: String = "language_name_" + language.code
        let localizedName: String = NSLocalizedString(localizedNameKey, comment: "")
        
        var languageName: String = ""
        
        if !localizedName.isEmpty && localizedName != localizedNameKey {
            languageName = localizedName
        }
        else {
            let locale: Locale
            if shouldFallbackToPrimaryLanguageLocale, let primaryLanguage = languageSettingsService.primaryLanguage.value {
                locale = Locale(identifier: primaryLanguage.code)
            }
            else {
                locale = Locale.current
            }
            languageName = locale.localizedString(forIdentifier: language.code) ?? ""
        }
        
        if languageName.isEmpty {
            languageName = language.name
        }
        
        self.name = languageName
    }
}
