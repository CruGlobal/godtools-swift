//
//  GetToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolsStringsDomainModel, Never> {
        
        let interfaceStrings = ToolsStringsDomainModel(
            favoritingToolBannerMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "tool_offline_favorite_message"),
            toolSpotlightTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ToolStringKeys.Spotlight.title.rawValue),
            toolSpotlightSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ToolStringKeys.Spotlight.subtitle.rawValue),
            filterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ToolStringKeys.ToolFilter.filterSectionTitle.rawValue),
            personalizedToolToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "dashboard.personalizedToolToggle.personalizedTitle"),
            allToolsToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "dashboard.personalizedToolToggle.allToolsTitle"),
            personalizedToolExplanationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "dashboard.personalizedToolFooter.title"),
            personalizedToolExplanationSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "dashboard.personalizedToolFooter.subtitle"),
            changePersonalizedToolSettingsActionLabel: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "dashboard.personalizedToolFooter.buttonTitle")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
