//
//  GetToolFilterLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetToolFilterLanguagesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> ToolFilterLanguagesStringsDomainModel {
        
        let localeId: String = appLanguage.localeId
        
        let strings = ToolFilterLanguagesStringsDomainModel(
            navTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolsFilterLanguageNavTitle.key)
        )
        
        return strings
    }
}
