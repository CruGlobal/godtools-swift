//
//  GetSearchBarInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSearchBarInterfaceStringsRepository: GetSearchBarInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    private let localeLanguageName: LocaleLanguageName
    
    init(localizationServices: LocalizationServices, localeLanguageName: LocaleLanguageName) {
        
        self.localizationServices = localizationServices
        self.localeLanguageName = localeLanguageName
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<SearchBarInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let interfaceStrings = SearchBarInterfaceStringsDomainModel(
            cancel: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "cancel")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
