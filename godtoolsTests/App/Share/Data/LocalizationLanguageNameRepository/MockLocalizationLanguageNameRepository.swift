//
//  MockLocalizationLanguageNameRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockLocalizationLanguageNameRepository: LocalizationLanguageNameRepositoryInterface {
    
    init() {
        
    }
    
    func getLanguageName(languageId: BCP47LanguageIdentifier, translatedInLanguage: BCP47LanguageIdentifier) -> String? {
        
        return nil
    }
}
