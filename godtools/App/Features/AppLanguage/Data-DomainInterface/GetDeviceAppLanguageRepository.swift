//
//  GetDeviceAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDeviceAppLanguageRepository: GetDeviceAppLanguageRepositoryInterface {
    
    private let deviceSystemLanguage: DeviceSystemLanguage
    
    init(deviceSystemLanguage: DeviceSystemLanguage) {
        
        self.deviceSystemLanguage = deviceSystemLanguage
    }
    
    func getDeviceAppLanguage() -> AppLanguageDomainModel {
        
        let locale: Locale = deviceSystemLanguage.getLocale()
        
        return (locale.languageCode ?? locale.identifier).lowercased()
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        let locale: Locale = deviceSystemLanguage.getLocale()
        
        let deviceLanguage: AppLanguageDomainModel = (locale.languageCode ?? locale.identifier).lowercased()
        
        return Just(deviceLanguage)
            .eraseToAnyPublisher()
    }
}
