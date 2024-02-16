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
            favoritingToolBannerMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ""),
            toolSpotlightTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ""),
            toolSpotlightSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: ""),
            filterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
