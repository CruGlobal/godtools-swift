//
//  GetConfirmRemoveToolFromFavoritesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetConfirmRemoveToolFromFavoritesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedToolName: GetTranslatedToolName
    
    init(localizationServices: LocalizationServicesInterface, getTranslatedToolName: GetTranslatedToolName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedToolName = getTranslatedToolName
    }
    
    func execute(toolId: String, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmRemoveToolFromFavoritesStringsDomainModel, Never> {
        
        let strings = ConfirmRemoveToolFromFavoritesStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.removeFromFavoritesTitle.key),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.removeFromFavoritesMessage.key).replacingOccurrences(of: "%@", with: getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: appLanguage)),
            confirmRemoveActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.yes.key),
            cancelRemoveActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.no.key)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
