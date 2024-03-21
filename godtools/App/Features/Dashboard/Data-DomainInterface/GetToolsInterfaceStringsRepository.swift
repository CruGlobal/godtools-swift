//
//  GetToolsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolsInterfaceStringsRepository: GetToolsInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolsInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = ToolsInterfaceStringsDomainModel(
            favoritingToolBannerMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "tool_offline_favorite_message"),
            toolSpotlightTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ToolStringKeys.Spotlight.title.rawValue),
            toolSpotlightSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ToolStringKeys.Spotlight.subtitle.rawValue),
            filterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ToolStringKeys.ToolFilter.filterSectionTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
