//
//  GetAllYourFavoritedToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetAllYourFavoritedToolsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AllYourFavoritedToolsStringsDomainModel, Never> {
        
        let strings = AllYourFavoritedToolsStringsDomainModel(
            sectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteToolsTitle.key)
        )

        return Just(strings)
            .eraseToAnyPublisher()
    }
}
