//
//  GetToolFilterCategoriesStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterCategoriesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterCategoriesStringsDomainModel, Never> {
        
        let localeId: String = appLanguage.localeId

        let strings = ToolFilterCategoriesStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: ToolStringKeys.ToolFilter.categoryFilterNavTitle.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
