//
//  GetConfirmRemoveToolFromFavoritesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetConfirmRemoveToolFromFavoritesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedToolName: GetTranslatedToolName
    
    init(localizationServices: LocalizationServicesInterface, getTranslatedToolName: GetTranslatedToolName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedToolName = getTranslatedToolName
    }
    
    func execute(toolId: String, appLanguage: AppLanguageDomainModel) async -> ConfirmRemoveToolFromFavoritesStringsDomainModel {
        
        let strings = ConfirmRemoveToolFromFavoritesStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.removeFromFavoritesTitle.key),
            message: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.removeFromFavoritesMessage.key).replacingOccurrences(of: "%@", with: getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: appLanguage)),
            confirmRemoveActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.yes.key),
            cancelRemoveActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.no.key)
        )
        
        return strings
    }
}
