//
//  GetToolDetailsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolDetailsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: String) -> AnyPublisher<ToolDetailsStringsDomainModel, Never> {
                        
        let localeId: String = appLanguage
        
        let strings = ToolDetailsStringsDomainModel(
            aboutActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.about.title"),
            addToFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "add_to_favorites"),
            bibleReferencesTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.bibleReferences.title"),
            conversationStartersTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.conversationStarters.title"),
            languagesAvailableTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.languagesAvailable.title"),
            learnToShareThisToolActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.learnToShareToolButton.title"),
            openToolActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolinfo_opentool"),
            outlineTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.outline.title"),
            removeFromFavoritesActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "remove_from_favorites"),
            versionsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolDetails.versions.title")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
