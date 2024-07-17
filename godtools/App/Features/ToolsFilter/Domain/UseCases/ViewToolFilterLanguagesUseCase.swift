//
//  ViewToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolFilterLanguagesUseCase {
    
    private let getToolFilterLanguagesRepository: GetToolFilterLanguagesRepositoryInterface
    private let getInterfaceStringsRepository: GetToolFilterLanguagesInterfaceStringsRepositoryInterface
    
    init(getToolFilterLanguagesRepository: GetToolFilterLanguagesRepositoryInterface, getInterfaceStringsRepository: GetToolFilterLanguagesInterfaceStringsRepositoryInterface) {
        
        self.getToolFilterLanguagesRepository = getToolFilterLanguagesRepository
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(filteredByCategoryId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolFilterLanguagesDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: translatedInAppLanguage),
            getToolFilterLanguagesRepository.getToolFilterLanguagesPublisher(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
        )
        .map { interfaceStrings, languageFilters in
            
            return ViewToolFilterLanguagesDomainModel(
                interfaceStrings: interfaceStrings,
                languageFilters: languageFilters
            )
        }
        .eraseToAnyPublisher()
    }
}
