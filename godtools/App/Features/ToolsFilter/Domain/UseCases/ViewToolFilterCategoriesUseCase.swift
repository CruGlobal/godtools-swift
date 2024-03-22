//
//  ViewToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolFilterCategoriesUseCase {
    
    private let getInterfaceStringsRepository: GetToolFilterCategoriesInterfaceStringsRepositoryInterface
    private let getToolFilterCategoriesRepository: GetToolFilterCategoriesRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolFilterCategoriesInterfaceStringsRepositoryInterface, getToolFilterCategoriesRepository: GetToolFilterCategoriesRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getToolFilterCategoriesRepository = getToolFilterCategoriesRepository
    }
    
    func viewPublisher(filteredByLanguageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolFilterCategoriesDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: translatedInAppLanguage),
            getToolFilterCategoriesRepository.getToolFilterCategoriesPublisher(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: filteredByLanguageId)
        )
        .map { interfaceStrings, categoryFilters in
            
            return ViewToolFilterCategoriesDomainModel(
                interfaceStrings: interfaceStrings,
                categoryFilters: categoryFilters
            )
        }
        .eraseToAnyPublisher()
    }
}
