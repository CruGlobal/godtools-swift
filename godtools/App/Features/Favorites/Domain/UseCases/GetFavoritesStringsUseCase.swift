//
//  GetFavoritesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetFavoritesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> FavoritesStringsDomainModel {

        let tutorialMessageKey: String = LocalizableStringKeys.openTutorialShowTutorialLabelText.key
        let openTutorialActionTitleKey: String = LocalizableStringKeys.openTutorialOpenTutorialButtonTitle.key
        let welcomeTitleKey: String = LocalizableStringKeys.favoritesPageTitle.key
        let featuredLessonsTitleKey: String = LocalizableStringKeys.favoritesFavoriteLessonsTitle.key
        let favoriteToolsTitleKey: String = LocalizableStringKeys.favoritesFavoriteToolsTitle.key
        let viewAllFavoritesActionTitleKey: String = LocalizableStringKeys.favoritesFavoriteToolsViewAll.key
        let noFavoritedToolsTitleKey: String = LocalizableStringKeys.favoritesNoToolsTitle.key
        let noFavoritedToolsDescriptionKey: String = LocalizableStringKeys.favoritesNoToolsDescription.key
        let noFavoritedToolsActionTitleKey: String = LocalizableStringKeys.favoritesNoToolsButton.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                tutorialMessageKey,
                openTutorialActionTitleKey,
                welcomeTitleKey,
                featuredLessonsTitleKey,
                favoriteToolsTitleKey,
                viewAllFavoritesActionTitleKey,
                noFavoritedToolsTitleKey,
                noFavoritedToolsDescriptionKey,
                noFavoritedToolsActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return FavoritesStringsDomainModel(
            tutorialMessage: strings[tutorialMessageKey] ?? "",
            openTutorialActionTitle: strings[openTutorialActionTitleKey] ?? "",
            welcomeTitle: strings[welcomeTitleKey] ?? "",
            featuredLessonsTitle: strings[featuredLessonsTitleKey] ?? "",
            favoriteToolsTitle: strings[favoriteToolsTitleKey] ?? "",
            viewAllFavoritesActionTitle: strings[viewAllFavoritesActionTitleKey] ?? "",
            noFavoritedToolsTitle: strings[noFavoritedToolsTitleKey] ?? "",
            noFavoritedToolsDescription: strings[noFavoritedToolsDescriptionKey] ?? "",
            noFavoritedToolsActionTitle: strings[noFavoritedToolsActionTitleKey] ?? ""
        )
    }
}
