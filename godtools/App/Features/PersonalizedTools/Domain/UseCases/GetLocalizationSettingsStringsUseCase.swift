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

    func execute(appLanguage: AppLanguageDomainModel) -> LocalizationSettingsStringsDomainModel {

        let navTitleKey: String = LocalizableStringKeys.localizationSettingsNavBarTitle.key
        let localizationHeaderTitleKey: String = LocalizableStringKeys.localizationSettingsLocalizationHeaderTitle.key
        let localizationHeaderDescriptionKey: String = LocalizableStringKeys.localizationSettingsLocalizationHeaderDescription.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey,
                localizationHeaderTitleKey,
                localizationHeaderDescriptionKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return LocalizationSettingsStringsDomainModel(
            navTitle: strings[navTitleKey] ?? "",
            localizationHeaderTitle: strings[localizationHeaderTitleKey] ?? "",
            localizationHeaderDescription: strings[localizationHeaderDescriptionKey] ?? ""
        )
    }
}
