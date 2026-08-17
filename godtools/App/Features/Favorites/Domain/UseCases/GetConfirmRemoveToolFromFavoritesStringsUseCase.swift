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
    
    func execute(toolId: String, appLanguage: AppLanguageDomainModel) -> ConfirmRemoveToolFromFavoritesStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.removeFromFavoritesTitle.key
        let messageKey: String = LocalizableStringKeys.removeFromFavoritesMessage.key
        let confirmRemoveActionTitleKey: String = LocalizableStringKeys.yes.key
        let cancelRemoveActionTitleKey: String = LocalizableStringKeys.no.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                messageKey,
                confirmRemoveActionTitleKey,
                cancelRemoveActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let toolName: String = getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: appLanguage)

        return ConfirmRemoveToolFromFavoritesStringsDomainModel(
            title: strings[titleKey] ?? "",
            message: (strings[messageKey] ?? "").replacingOccurrences(of: "%@", with: toolName),
            confirmRemoveActionTitle: strings[confirmRemoveActionTitleKey] ?? "",
            cancelRemoveActionTitle: strings[cancelRemoveActionTitleKey] ?? ""
        )
    }
}
