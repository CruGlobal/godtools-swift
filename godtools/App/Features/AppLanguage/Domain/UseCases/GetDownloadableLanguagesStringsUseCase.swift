//
//  GetDownloadableLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetDownloadableLanguagesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> DownloadableLanguagesStringsDomainModel {

        let navTitleKey: String = LocalizableStringKeys.languageSettingsDownloadableLanguagesTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return DownloadableLanguagesStringsDomainModel(
            navTitle: strings[navTitleKey] ?? ""
        )
    }
}
