//
//  ViewToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolsUseCase {
    
    private let getInterfaceStringsRepository: GetToolsInterfaceStringsRepositoryInterface
    private let getToolsRepository: GetToolsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolsInterfaceStringsRepositoryInterface, getToolsRepository: GetToolsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getToolsRepository = getToolsRepository
    }
    
    func viewPublisher(translatedInAppLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?, filterToolsByCategory: ToolFilterCategoryDomainModelInterface?, filterToolsByLanguage: ToolFilterLanguageDomainModel?) -> AnyPublisher<ViewToolsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: translatedInAppLanguage),
            getToolsRepository.getToolsPublisher(
                translatedInAppLanguage: translatedInAppLanguage,
                languageIdForAvailabilityText: languageIdForAvailabilityText,
                filterToolsByCategory: filterToolsByCategory,
                filterToolsByLanguage: filterToolsByLanguage
            )
        )
        .map {
            
            ViewToolsDomainModel(
                interfaceStrings: $0,
                tools: $1
            )
        }
        .eraseToAnyPublisher()
    }
}
