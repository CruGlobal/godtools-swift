//
//  GetToolSettingsToolLanguagesListStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolSettingsToolLanguagesListStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolSettingsToolLanguagesListStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ToolSettingsToolLanguagesListStringsDomainModel(
            deleteParallelLanguageActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsLanguagesListDeleteLanguageTitle.key)
        )
        
        return strings
    }
}
