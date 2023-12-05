//
//  GetDownloadableLanguagesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadableLanguagesInterfaceStringsRepository: GetDownloadableLanguagesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName
    
    init(localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
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
