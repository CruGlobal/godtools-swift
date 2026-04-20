//
//  GetToolSettingsToolLanguagesListStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolSettingsToolLanguagesListStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguagesListStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = ToolSettingsToolLanguagesListStringsDomainModel(
            deleteParallelLanguageActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.languagesList.deleteLanguage.title")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
