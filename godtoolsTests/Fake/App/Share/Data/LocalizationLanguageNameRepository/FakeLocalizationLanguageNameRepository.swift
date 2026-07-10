//
//  FakeLocalizationLanguageNameRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class FakeLocalizationLanguageNameRepository: LocalizationLanguageNameInterface {
    
    private let localizationServices: FakeLocalizationServices
    
    init(localizationServices: FakeLocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getLanguageName(languageId: BCP47LanguageIdentifier, translatedInLanguage: BCP47LanguageIdentifier) -> String? {
        
        return localizationServices.stringForLocaleElseEnglish(localeIdentifier: translatedInLanguage, key: languageId)
    }
}
