//
//  GetToolDetailsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsInterfaceStringsRepository: GetToolDetailsInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInToolLanguageCode: String) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> {
                        
        let localeId: String = translateInToolLanguageCode
        
        let interfaceStrings = ToolDetailsInterfaceStringsDomainModel(
            aboutButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.about.title"),
            addToFavoritesButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "add_to_favorites"),
            bibleReferencesTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.bibleReferences.title"),
            conversationStartersTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.conversationStarters.title"),
            languagesAvailableTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.languagesAvailable.title"),
            learnToShareThisToolButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.learnToShareToolButton.title"),
            openToolButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolinfo_opentool"),
            outlineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.outline.title"),
            removeFromFavoritesButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "remove_from_favorites"),
            versionsButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.versions.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
