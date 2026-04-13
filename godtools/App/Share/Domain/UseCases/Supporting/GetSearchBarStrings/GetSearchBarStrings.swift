//
//  GetSearchBarStrings.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSearchBarStrings {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<SearchBarStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let strings = SearchBarStringsDomainModel(
            cancel: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "cancel")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
