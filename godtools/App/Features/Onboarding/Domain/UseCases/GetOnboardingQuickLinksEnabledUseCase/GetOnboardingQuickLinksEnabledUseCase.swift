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
            LanguageCode.english.value,
            LanguageCode.french.value,
            LanguageCode.latvian.value,
            LanguageCode.spanish.value,
            LanguageCode.vietnamese.value
        ]
        
        let languageCode = getDeviceLanguageUseCase.getDeviceLanguageValue().localeLanguageCode
        
        return supportedLanguageCodes.contains(languageCode)
    }
}
