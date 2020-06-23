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
    let primaryLanguageId: String
    let primaryLanguageTranslation: TranslationModel?
    let fallbackLanguageCode: String
    let fallbackLanguageTranslation: TranslationModel?
    let resourceSupportsPrimaryLanguage: Bool
    
    var preferredLanguageTranslation: TranslationModel? {
        return resourceSupportsPrimaryLanguage ? primaryLanguageTranslation : fallbackLanguageTranslation
    }
    
    func log() {
        print("\n PreferredLanguageTranslationResult")
        print("  resourceId: \(resourceId)")
        print("  primaryLanguageId: \(primaryLanguageId)")
        print("  primaryLanguageTranslation: \(String(describing: primaryLanguageTranslation))")
        print("  fallbackLanguageCode: \(fallbackLanguageCode)")
        print("  fallbackLanguageTranslation: \(String(describing: fallbackLanguageTranslation))")
        print("  resourceSupportsPrimaryLanguage: \(resourceSupportsPrimaryLanguage)")
        print("  preferredLanguageTranslation: \(String(describing: preferredLanguageTranslation))")
    }
}
