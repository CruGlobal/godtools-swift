//
//  GetFavoritesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFavoritesInterfaceStringsRepository: GetFavoritesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<FavoritesInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = FavoritesInterfaceStringsDomainModel(
            tutorialMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "openTutorial.showTutorialLabel.text"),
            openTutorialActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "openTutorial.openTutorialButton.title"),
            pageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.pageTitle"),
            featuredLessonsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.favoriteLessons.title"),
            favoriteToolsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.favoriteTools.title"),
            viewAllFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.favoriteTools.viewAll"),
            noFavoritedToolsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.noTools.title"),
            noFavoritedToolsDescription: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.noTools.description"),
            noFavoritedToolsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "favorites.noTools.button")
        )

        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
