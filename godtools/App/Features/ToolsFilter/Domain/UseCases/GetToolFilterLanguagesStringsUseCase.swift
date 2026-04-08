//
//  GetToolFilterLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterLanguagesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguagesStringsDomainModel, Never> {
        
        let localeId: String = appLanguage.localeId
        
        let strings = ToolFilterLanguagesStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: ToolStringKeys.ToolFilter.languageFilterNavTitle.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
