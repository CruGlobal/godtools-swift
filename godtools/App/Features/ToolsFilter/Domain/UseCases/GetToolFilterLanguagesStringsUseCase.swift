//
//  GetToolFilterLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetToolFilterLanguagesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolFilterLanguagesStringsDomainModel {

        let localeId: String = appLanguage.localeId

        let navTitleKey: String = LocalizableStringKeys.toolsFilterLanguageNavTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ToolFilterLanguagesStringsDomainModel(
            navTitle: strings[navTitleKey] ?? ""
        )
    }
}
