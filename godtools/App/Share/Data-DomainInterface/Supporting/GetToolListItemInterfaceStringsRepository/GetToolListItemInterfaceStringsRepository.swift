//
//  GetToolListItemInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolListItemInterfaceStringsRepository {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolListItemInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = ToolListItemInterfaceStringsDomainModel(
            openToolActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "open"),
            openToolDetailsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.favoriteLessons.details")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
