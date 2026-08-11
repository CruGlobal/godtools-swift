//
//  GetFavoritesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetFavoritesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> FavoritesStringsDomainModel {
        
        let strings = FavoritesStringsDomainModel(
            tutorialMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.openTutorialShowTutorialLabelText.key),
            openTutorialActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.openTutorialOpenTutorialButtonTitle.key),
            welcomeTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesPageTitle.key),
            featuredLessonsTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteLessonsTitle.key),
            favoriteToolsTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteToolsTitle.key),
            viewAllFavoritesActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteToolsViewAll.key),
            noFavoritedToolsTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesNoToolsTitle.key),
            noFavoritedToolsDescription: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesNoToolsDescription.key),
            noFavoritedToolsActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesNoToolsButton.key)
        )

        return strings
    }
}
