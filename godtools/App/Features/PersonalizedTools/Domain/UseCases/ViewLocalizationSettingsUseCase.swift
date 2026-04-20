//
//  ViewLocalizationSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLocalizationSettingsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LocalizationSettingsStringsDomainModel, Never> {

        let strings = LocalizationSettingsStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.navBar.title"),
            localizationHeaderTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.localizationHeader.title"),
            localizationHeaderDescription: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.localizationHeader.description")
        )

        return Just(strings)
            .eraseToAnyPublisher()
    }
}
