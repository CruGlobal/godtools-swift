//
//  GetDownloadableLanguagesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetDownloadableLanguagesInterfaceStringsRepository: GetDownloadableLanguagesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadableLanguagesInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let interfaceStrings = DownloadableLanguagesInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: AppLanguageStringKeys.DownloadableLanguages.navTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
