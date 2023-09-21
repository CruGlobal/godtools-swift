//
//  DeviceSystemLanguage+GetDeviceLanguageInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension DeviceSystemLanguage: GetDeviceLanguageInterface {
    
    func getDeviceLanguage() -> DeviceLanguageDomainModel {
        
        let locale: Locale = getLocale()
        
        return DeviceLanguageDomainModel(
            languageCode: (locale.languageCode ?? locale.identifier).lowercased()
        )
    }
}
