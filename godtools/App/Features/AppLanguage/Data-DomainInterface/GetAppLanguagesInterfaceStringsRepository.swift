//
//  GetAppLanguagesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguagesInterfaceStringsRepository: GetAppLanguagesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguagesInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = AppLanguagesInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: AppLanguageStringKeys.AppLanguages.navTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
