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
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "remove_from_favorites_title"),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: appLanguage)),
            confirmRemoveActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "yes"),
            cancelRemoveActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "no")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
