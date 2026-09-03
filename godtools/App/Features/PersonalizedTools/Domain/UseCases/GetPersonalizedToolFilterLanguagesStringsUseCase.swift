//
//  GetPersonalizedToolFilterLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetPersonalizedToolFilterLanguagesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> PersonalizedToolFilterLanguagesStringsDomainModel {

        let localeId: String = appLanguage.localeId

        let navTitleKey: String = LocalizableStringKeys.toolsFilterLanguageNavTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return PersonalizedToolFilterLanguagesStringsDomainModel(
            navTitle: strings[navTitleKey] ?? ""
        )
    }
}
