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
            LanguageCodeDomainModel.english.value,
            LanguageCodeDomainModel.french.value,
            LanguageCodeDomainModel.latvian.value,
            LanguageCodeDomainModel.spanish.value,
            LanguageCodeDomainModel.vietnamese.value
        ]
        
        let languageCode: String = getDeviceLanguageUseCase.getDeviceLanguage().languageCode
        
        return supportedLanguageCodes.contains(languageCode)
    }
}
