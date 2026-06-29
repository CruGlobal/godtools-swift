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
    
    func execute(appLanguage: String) -> ToolDetailsStringsDomainModel {
                        
        let localeId: String = appLanguage
        
        let strings = ToolDetailsStringsDomainModel(
            aboutActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsAboutTitle.key),
            addToFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.addToFavorites.key),
            bibleReferencesTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsBibleReferencesTitle.key),
            conversationStartersTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsConversationStartersTitle.key),
            languagesAvailableTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsLanguagesAvailableTitle.key),
            learnToShareThisToolActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsLearnToShareToolButtonTitle.key),
            openToolActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolinfoOpentool.key),
            outlineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsOutlineTitle.key),
            removeFromFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.removeFromFavorites.key),
            versionsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolDetailsVersionsTitle.key)
        )
        
        return strings
    }
}
