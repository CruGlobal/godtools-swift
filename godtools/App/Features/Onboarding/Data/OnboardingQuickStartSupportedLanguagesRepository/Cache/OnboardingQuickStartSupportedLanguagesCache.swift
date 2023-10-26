//
//  OnboardingQuickStartSupportedLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartSupportedLanguagesCache {
    
    private let supportedLanguages: [LanguageCodeDomainModel] = [.english, .french, .latvian, .spanish, .vietnamese]
    
    init() {
        
    }
    
    func getSupportedLanguages() -> [LanguageCodeDomainModel] {
        return supportedLanguages
    }
}
