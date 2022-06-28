//
//  GetOnboardingQuickLinksEnabledUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetOnboardingQuickLinksEnabledUseCase {
    
    private let deviceLanguage: DeviceLanguageType
    
    init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
    }
    
    func getQuickLinksEnabled() -> Bool {
        
        let supportedLanguageCodes: [String] = ["en", "fr", "lv", "vi"]
        
        let deviceLocale: Locale = deviceLanguage.preferredLocalizationLocale ?? deviceLanguage.locale
        
        let languageCode: String = (deviceLocale.languageCode ?? deviceLocale.identifier).lowercased()
        
        return supportedLanguageCodes.contains(languageCode)
    }
}
