//
//  GetFavoritesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetFavoritesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<FavoritesStringsDomainModel, Never> {
        
        let strings = FavoritesStringsDomainModel(
            tutorialMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "openTutorial.showTutorialLabel.text"),
            openTutorialActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "openTutorial.openTutorialButton.title"),
            welcomeTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.pageTitle"),
            featuredLessonsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.favoriteLessons.title"),
            favoriteToolsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.favoriteTools.title"),
            viewAllFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.favoriteTools.viewAll"),
            noFavoritedToolsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.noTools.title"),
            noFavoritedToolsDescription: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.noTools.description"),
            noFavoritedToolsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "favorites.noTools.button")
        )

        return Just(strings)
            .eraseToAnyPublisher()
    }
}
