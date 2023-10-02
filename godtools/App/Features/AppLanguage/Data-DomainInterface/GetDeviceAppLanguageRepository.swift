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
    
    func getDeviceAppLanguage() -> AppLanguageCodeDomainModel {
        
        let locale: Locale = deviceSystemLanguage.getLocale()
        
        return (locale.languageCode ?? locale.identifier).lowercased()
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageCodeDomainModel, Never> {
        
        let locale: Locale = deviceSystemLanguage.getLocale()
        
        let deviceLanguage: AppLanguageCodeDomainModel = (locale.languageCode ?? locale.identifier).lowercased()
        
        return Just(deviceLanguage)
            .eraseToAnyPublisher()
    }
}
