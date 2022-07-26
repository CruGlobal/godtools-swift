//
//  GetDeviceLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetDeviceLanguageUseCase {
    
    private let deviceLanguage: DeviceLanguageType
    
    init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
    }
    
    func getDeviceLanguage() -> DeviceLanguageDomainModel {
        
        let deviceLocale: Locale = deviceLanguage.preferredLocalizationLocale ?? deviceLanguage.locale
        
        let languageCode = (deviceLocale.languageCode ?? deviceLocale.identifier).lowercased()
        
        return DeviceLanguageDomainModel(languageCode: languageCode)
    }
}
