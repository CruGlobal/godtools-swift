//
//  PreferredLanguageTranslationResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct PreferredLanguageTranslationResult {
    
    let resourceId: String
    let primaryLanguage: LanguageModel?
    let primaryLanguageTranslation: TranslationModel?
    let fallbackLanguage: LanguageModel?
    let fallbackLanguageTranslation: TranslationModel?
    
    var resourceSupportsPrimaryLanguageTranslation: Bool {
        return primaryLanguage != nil && primaryLanguageTranslation != nil
    }
    
    var preferredLanguage: LanguageModel? {
        return primaryLanguage ?? fallbackLanguage
    }
    
    var preferredLanguageTranslation: TranslationModel? {
        return primaryLanguageTranslation ?? fallbackLanguageTranslation
    }
}
