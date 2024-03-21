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
    
    init(getToolFilterLanguagesRepository: GetToolFilterLanguagesRepositoryInterface) {
        
        self.getToolFilterLanguagesRepository = getToolFilterLanguagesRepository
    }
    
    func viewPublisher(filteredByCategoryId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolFilterLanguagesDomainModel, Never> {
        
        return getToolFilterLanguagesRepository.getToolFilterLanguagesPublisher(translatedInAppLanguage: translatedInAppLanguage, filteredByCategoryId: filteredByCategoryId)
            .map { languageFilters in
                
                return ViewToolFilterLanguagesDomainModel(
                    languageFilters: languageFilters
                )
            }
            .eraseToAnyPublisher()
    }
}
