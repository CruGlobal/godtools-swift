//
//  GetDeviceLanguageCodeUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetDeviceLanguageCodeUseCase {
    
    private let deviceLanguage: DeviceLanguageType
    
    init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
    }
    
    func getDeviceLanguageCode() -> String {
        
        let deviceLocale: Locale = deviceLanguage.preferredLocalizationLocale ?? deviceLanguage.locale
        
        return (deviceLocale.languageCode ?? deviceLocale.identifier).lowercased()
    }
}
