//
//  GetToolDetailsInterfaceStringsInToolLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsInterfaceStringsInToolLanguageUseCase {
    
    private let getInterfaceStringForLanguageRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface
    
    init(getInterfaceStringForLanguageRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface) {
        
        self.getInterfaceStringForLanguageRepositoryInterface = getInterfaceStringForLanguageRepositoryInterface
    }
    
    func getStringsPublisher(toolLanguageCodePublisher: AnyPublisher<String, Never>) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> {
        
        toolLanguageCodePublisher
        .flatMap({ (languageCode: String) -> AnyPublisher<ToolDetailsInterfaceStringsDomainModel, Never> in
            
            let stringsRepository = self.getInterfaceStringForLanguageRepositoryInterface
            
            let interfaceStrings = ToolDetailsInterfaceStringsDomainModel(
                aboutButtonTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolDetails.about.title"),
                addToFavoritesButtonTitle: stringsRepository.getString(languageCode: languageCode, stringId: "add_to_favorites"),
                bibleReferencesTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolDetails.bibleReferences.title"),
                conversationStartersTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolDetails.conversationStarters.title"),
                languagesAvailableTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolSettings.languagesAvailable.title"),
                learnToShareThisToolButtonTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolDetails.learnToShareToolButton.title"),
                openToolButtonTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolinfo_opentool"),
                outlineTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolDetails.outline.title"),
                removeFromFavoritesButtonTitle: stringsRepository.getString(languageCode: languageCode, stringId: "remove_from_favorites"),
                versionsButtonTitle: stringsRepository.getString(languageCode: languageCode, stringId: "toolDetails.versions.title")
            )
            
            return Just(interfaceStrings)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
