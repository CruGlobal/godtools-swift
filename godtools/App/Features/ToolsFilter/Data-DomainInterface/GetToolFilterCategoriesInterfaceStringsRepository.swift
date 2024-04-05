//
//  GetToolFilterCategoriesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolFilterCategoriesInterfaceStringsRepository: GetToolFilterCategoriesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterCategoriesInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage.localeId

        let interfaceStrings = ToolFilterCategoriesInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
