//
//  GetToolDetailsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolDetailsStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: String) -> ToolDetailsStringsDomainModel {

        let aboutActionTitleKey: String = LocalizableStringKeys.toolDetailsAboutTitle.key
        let addToFavoritesActionTitleKey: String = LocalizableStringKeys.addToFavorites.key
        let bibleReferencesTitleKey: String = LocalizableStringKeys.toolDetailsBibleReferencesTitle.key
        let conversationStartersTitleKey: String = LocalizableStringKeys.toolDetailsConversationStartersTitle.key
        let languagesAvailableTitleKey: String = LocalizableStringKeys.toolSettingsLanguagesAvailableTitle.key
        let learnToShareThisToolActionTitleKey: String = LocalizableStringKeys.toolDetailsLearnToShareToolButtonTitle.key
        let openToolActionTitleKey: String = LocalizableStringKeys.toolinfoOpentool.key
        let outlineTitleKey: String = LocalizableStringKeys.toolDetailsOutlineTitle.key
        let removeFromFavoritesActionTitleKey: String = LocalizableStringKeys.removeFromFavorites.key
        let versionsActionTitleKey: String = LocalizableStringKeys.toolDetailsVersionsTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                aboutActionTitleKey,
                addToFavoritesActionTitleKey,
                bibleReferencesTitleKey,
                conversationStartersTitleKey,
                languagesAvailableTitleKey,
                learnToShareThisToolActionTitleKey,
                openToolActionTitleKey,
                outlineTitleKey,
                removeFromFavoritesActionTitleKey,
                versionsActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ToolDetailsStringsDomainModel(
            aboutActionTitle: strings[aboutActionTitleKey] ?? "",
            addToFavoritesActionTitle: strings[addToFavoritesActionTitleKey] ?? "",
            bibleReferencesTitle: strings[bibleReferencesTitleKey] ?? "",
            conversationStartersTitle: strings[conversationStartersTitleKey] ?? "",
            languagesAvailableTitle: strings[languagesAvailableTitleKey] ?? "",
            learnToShareThisToolActionTitle: strings[learnToShareThisToolActionTitleKey] ?? "",
            openToolActionTitle: strings[openToolActionTitleKey] ?? "",
            outlineTitle: strings[outlineTitleKey] ?? "",
            removeFromFavoritesActionTitle: strings[removeFromFavoritesActionTitleKey] ?? "",
            versionsActionTitle: strings[versionsActionTitleKey] ?? ""
        )
    }
}
