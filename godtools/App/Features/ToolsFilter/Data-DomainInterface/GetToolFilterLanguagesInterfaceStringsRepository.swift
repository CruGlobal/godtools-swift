//
//  GetToolFilterLanguagesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolFilterLanguagesInterfaceStringsRepository: GetToolFilterLanguagesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguagesInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage.localeId
        
        let interfaceStrings = ToolFilterLanguagesInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
