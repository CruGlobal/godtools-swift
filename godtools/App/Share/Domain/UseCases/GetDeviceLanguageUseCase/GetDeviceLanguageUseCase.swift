//
//  GetDeviceLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDeviceLanguageUseCase {
       
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(getLanguageUseCase: GetLanguageUseCase) {
        
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getDeviceLanguagePublisher() -> AnyPublisher<DeviceLanguageDomainModel, Never> {
        
        return Just(getDeviceLanguageValue())
            .eraseToAnyPublisher()
    }
    
    func getDeviceLanguageValue() -> DeviceLanguageDomainModel {
                
        let deviceLocale: Locale = getDeviceLocale()
        
        return getDeviceLanguage(for: deviceLocale)
    }
    
    private func getDeviceLanguage(for locale: Locale) -> DeviceLanguageDomainModel {
        
        return DeviceLanguageDomainModel(
            language: getLanguageUseCase.getLanguage(locale: locale),
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
