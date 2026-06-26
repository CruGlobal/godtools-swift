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
            tutorialMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.openTutorialShowTutorialLabelText.key),
            openTutorialActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.openTutorialOpenTutorialButtonTitle.key),
            welcomeTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesPageTitle.key),
            featuredLessonsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteLessonsTitle.key),
            favoriteToolsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteToolsTitle.key),
            viewAllFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteToolsViewAll.key),
            noFavoritedToolsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesNoToolsTitle.key),
            noFavoritedToolsDescription: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesNoToolsDescription.key),
            noFavoritedToolsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesNoToolsButton.key)
        )

        return Just(strings)
            .eraseToAnyPublisher()
    }
}
