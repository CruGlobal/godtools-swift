//
//  GetToolListItemStrings.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetToolListItemStrings: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStrings(appLanguage: AppLanguageDomainModel) -> ToolListItemStringsDomainModel {
        
        let openToolActionTitleKey: String = LocalizableStringKeys.open.key
        let openToolDetailsActionTitleKey: String = LocalizableStringKeys.favoritesFavoriteLessonsDetails.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                openToolActionTitleKey,
                openToolDetailsActionTitleKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        return ToolListItemStringsDomainModel(
            openToolActionTitle: strings[openToolActionTitleKey] ?? "",
            openToolDetailsActionTitle: strings[openToolDetailsActionTitleKey] ?? ""
        )
    }
}
