//
//  GetDeviceAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetDeviceAppLanguageRepository: GetDeviceAppLanguageRepositoryInterface {
    
    private let deviceSystemLanguage: DeviceSystemLanguage
    
    init(deviceSystemLanguage: DeviceSystemLanguage) {
        
        self.deviceSystemLanguage = deviceSystemLanguage
    }
    
    func getDeviceAppLanguage() -> AppLanguageCodeDomainModel {
        
        let locale: Locale = deviceSystemLanguage.getLocale()
        
        return (locale.languageCode ?? locale.identifier).lowercased()
    }
}
