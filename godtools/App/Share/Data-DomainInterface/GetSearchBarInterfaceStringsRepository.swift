//
//  GetSearchBarInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetSearchBarInterfaceStringsRepository: GetSearchBarInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
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
