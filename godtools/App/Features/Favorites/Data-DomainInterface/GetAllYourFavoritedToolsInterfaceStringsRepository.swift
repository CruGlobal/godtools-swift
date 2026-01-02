//
//  GetAllYourFavoritedToolsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllYourFavoritedToolsInterfaceStringsRepository: GetAllYourFavoritedToolsInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    @MainActor func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<AllYourFavoritedToolsInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = AllYourFavoritedToolsInterfaceStringsDomainModel(
            sectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.favoriteTools.title")
        )

        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
