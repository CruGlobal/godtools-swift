//
//  GetLocalizationSettingsStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetLocalizationSettingsStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel) async -> LocalizationSettingsStringsDomainModel {

        let strings = LocalizationSettingsStringsDomainModel(
            navTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsNavBarTitle.key),
            localizationHeaderTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsLocalizationHeaderTitle.key),
            localizationHeaderDescription: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsLocalizationHeaderDescription.key)
        )

        return strings
    }
}
