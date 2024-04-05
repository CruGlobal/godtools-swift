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
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguagesInterfaceStringsDomainModel, Never> {
        
        let stringsFileType: LocalizableStringsFileType = .strings
        
        let interfaceStrings = AppLanguagesInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: AppLanguageStringKeys.AppLanguages.navTitle.rawValue, fileType: stringsFileType)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
