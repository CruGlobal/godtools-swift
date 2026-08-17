//
//  LocalizationLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 7/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class LocalizationLanguageName: LocalizationLanguageNameInterface {
    
    // NOTE: If this list grows too large it could impact performance where UI lists of language names are displayed since
    // it would require opening a bundle for every language in this list. ~Levi
    private static let supportedLanguageIds: [BCP47LanguageIdentifier] = ["fa", "fil", "fil-x-taglish", "sid"]
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getLanguageName(
        languageId: BCP47LanguageIdentifier,
        translatedInLanguage: BCP47LanguageIdentifier
    ) async -> String? {
        
        guard LocalizationLanguageName.supportedLanguageIds.contains(languageId) else {
            return nil
        }
        
        let localizedKey: String = "language_name_" + languageId
        
        let localizedName: String = localizationServices.stringForLocaleElseEnglishElseKey(
            localeIdentifier: translatedInLanguage,
            key: localizedKey
        )
        
        if localizedName.isEmpty || localizedName == localizedKey {
            return nil
        }
        
        return localizedName
    }
}
