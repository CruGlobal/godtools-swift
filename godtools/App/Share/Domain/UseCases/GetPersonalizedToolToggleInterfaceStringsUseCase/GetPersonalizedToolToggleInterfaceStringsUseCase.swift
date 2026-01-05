//
//  GetPersonalizedToolToggleInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetPersonalizedToolToggleInterfaceStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<PersonalizedToolToggleInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = PersonalizedToolToggleInterfaceStringsDomainModel(
            personalizedText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "dashboard.personalizedToolToggle.personalizedTitle"),
            allToolsText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "dashboard.personalizedToolToggle.allToolsTitle"),
            allLessonsText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "dashboard.personalizedToolToggle.allLessonsTitle")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
