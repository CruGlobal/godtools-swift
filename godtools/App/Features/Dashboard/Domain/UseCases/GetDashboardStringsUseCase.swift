//
//  GetDashboardStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetDashboardStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> DashboardStringsDomainModel {

        let lessonsActionTitleKey: String = LocalizableStringKeys.toolMenuItemLessons.key
        let favoritesActionTitleKey: String = LocalizableStringKeys.myTools.key
        let toolsActionTitleKey: String = LocalizableStringKeys.toolMenuItemTools.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                lessonsActionTitleKey,
                favoritesActionTitleKey,
                toolsActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translateInLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return DashboardStringsDomainModel(
            lessonsActionTitle: strings[lessonsActionTitleKey] ?? "",
            favoritesActionTitle: strings[favoritesActionTitleKey] ?? "",
            toolsActionTitle: strings[toolsActionTitleKey] ?? ""
        )
    }
}
