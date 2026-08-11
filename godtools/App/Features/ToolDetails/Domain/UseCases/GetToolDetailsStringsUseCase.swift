//
//  GetToolDetailsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolDetailsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: String) async -> ToolDetailsStringsDomainModel {
                        
        let localeId: String = appLanguage
        
        let strings = ToolDetailsStringsDomainModel(
            aboutActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsAboutTitle.key),
            addToFavoritesActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.addToFavorites.key),
            bibleReferencesTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsBibleReferencesTitle.key),
            conversationStartersTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsConversationStartersTitle.key),
            languagesAvailableTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsLanguagesAvailableTitle.key),
            learnToShareThisToolActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsLearnToShareToolButtonTitle.key),
            openToolActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolinfoOpentool.key),
            outlineTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsOutlineTitle.key),
            removeFromFavoritesActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.removeFromFavorites.key),
            versionsActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsVersionsTitle.key)
        )
        
        return strings
    }
}
