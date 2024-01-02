//
//  GetToolSettingsToolLanguagesListInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsToolLanguagesListInterfaceStringsRepository: GetToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguagesListInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = ToolSettingsToolLanguagesListInterfaceStringsDomainModel(
            deleteParallelLanguageActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.languagesList.deleteLanguage.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
