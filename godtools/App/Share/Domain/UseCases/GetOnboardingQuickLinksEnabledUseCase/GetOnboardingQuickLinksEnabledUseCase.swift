//
//  GetOnboardingQuickLinksEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOnboardingQuickLinksEnabledUseCase {
    
    private let getDeviceLanguageCodeUseCase: GetDeviceLanguageCodeUseCase
    
    init(getDeviceLanguageCodeUseCase: GetDeviceLanguageCodeUseCase) {
        
        self.getDeviceLanguageCodeUseCase = getDeviceLanguageCodeUseCase
    }
    
    func getQuickLinksEnabled() -> Bool {
        
        let supportedLanguageCodes: [String] = [LanguageCodes.English, LanguageCodes.French, LanguageCodes.Latvian, LanguageCodes.Vietnamese]
        
        let languageCode = getDeviceLanguageCodeUseCase.getDeviceLanguageCode()
        
        return supportedLanguageCodes.contains(languageCode)
    }
}
