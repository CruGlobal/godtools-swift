//
//  GetAllYourFavoritedToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetAllYourFavoritedToolsStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AllYourFavoritedToolsStringsDomainModel {

        let sectionTitleKey: String = LocalizableStringKeys.favoritesFavoriteToolsTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                sectionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return AllYourFavoritedToolsStringsDomainModel(
            sectionTitle: strings[sectionTitleKey] ?? ""
        )
    }
}
