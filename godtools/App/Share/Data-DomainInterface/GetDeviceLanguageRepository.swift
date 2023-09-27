//
//  GetDeviceLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetDeviceLanguageRepository: GetDeviceLanguageRepositoryInterface {
    
    private let deviceSystemLanguage: DeviceSystemLanguage
    
    init(deviceSystemLanguage: DeviceSystemLanguage) {
        
        self.deviceSystemLanguage = deviceSystemLanguage
    }
    
    func getDeviceLanguage() -> DeviceLanguageDomainModel {
        
        let locale: Locale = deviceSystemLanguage.getLocale()
        
        let languageCode: String = (locale.languageCode ?? locale.identifier).lowercased()
        
        return DeviceLanguageDomainModel(languageCode: languageCode)
    }
}
