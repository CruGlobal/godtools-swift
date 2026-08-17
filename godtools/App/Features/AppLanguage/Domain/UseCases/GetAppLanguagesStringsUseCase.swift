//
//  GetAppLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetAppLanguagesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AppLanguagesStringsDomainModel {

        let navTitleKey: String = LocalizableStringKeys.languageSettingsAppLanguageTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return AppLanguagesStringsDomainModel(
            navTitle: strings[navTitleKey] ?? ""
        )
    }
}
