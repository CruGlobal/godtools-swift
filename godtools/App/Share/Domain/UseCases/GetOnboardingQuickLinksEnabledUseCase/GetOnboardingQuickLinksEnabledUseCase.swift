//
//  GetOnboardingQuickLinksEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOnboardingQuickLinksEnabledUseCase {
    
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    
    init(getDeviceLanguageUseCase: GetDeviceLanguageUseCase) {
        
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
    }
    
    func getQuickLinksEnabled() -> Bool {
        
        let supportedLanguageCodes: [String] = [
            LanguageCodes.english,
            LanguageCodes.french,
            LanguageCodes.latvian,
            LanguageCodes.spanish,
            LanguageCodes.vietnamese
        ]
        
        let languageCode = getDeviceLanguageUseCase.getDeviceLanguage().localeLanguageCode
        
        return supportedLanguageCodes.contains(languageCode)
    }
}
