//
//  GetConfirmRemoveToolFromFavoritesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetConfirmRemoveToolFromFavoritesInterfaceStringsRepository: GetConfirmRemoveToolFromFavoritesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    private let getTranslatedToolName: GetTranslatedToolName
    
    init(localizationServices: LocalizationServices, getTranslatedToolName: GetTranslatedToolName) {
        
        self.localizationServices = localizationServices
        self.getTranslatedToolName = getTranslatedToolName
    }
    
    func getStringsPublisher(toolId: String, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ConfirmRemoveToolFromFavoritesInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = ConfirmRemoveToolFromFavoritesInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "remove_from_favorites_title"),
            message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: getTranslatedToolName.getToolName(toolId: toolId, translateInLanguage: translateInLanguage)),
            confirmRemoveActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "yes"),
            cancelRemoveActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "no")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
