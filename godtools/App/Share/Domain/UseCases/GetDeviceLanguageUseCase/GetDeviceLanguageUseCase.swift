//
//  GetDeviceLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetDeviceLanguageUseCase {
            
    init() {
        
    }
    
    func getDeviceLanguage() -> DeviceLanguageDomainModel {
                
        let deviceLocale: Locale = getDeviceLocale()
        
        return getDeviceLanguage(for: deviceLocale)
    }
    
    private func getDeviceLanguage(for locale: Locale) -> DeviceLanguageDomainModel {
        
        return DeviceLanguageDomainModel(
            locale: locale,
            localeIdentifier: locale.identifier,
            localeLanguageCode: (locale.languageCode ?? locale.identifier).lowercased()
        )
    }
    
    private func getDeviceLocale() -> Locale {
        
        if let localeIdentifier = Bundle.main.preferredLocalizations.first {
            return Locale(identifier: localeIdentifier)
        }
        
        return Locale.current
    }
}
