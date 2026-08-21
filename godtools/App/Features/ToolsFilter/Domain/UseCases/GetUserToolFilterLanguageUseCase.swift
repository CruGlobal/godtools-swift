//
//  GetUserToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserToolFilterLanguageUseCase: Sendable {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    private let getToolFilterLanguage: GetToolFilterLanguage
    
    init(userToolFiltersRepository: UserToolFiltersRepository, getToolFilterLanguage: GetToolFilterLanguage) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
        self.getToolFilterLanguage = getToolFilterLanguage
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<ToolFilterLanguageDomainModel, Never> {
        
        return userToolFiltersRepository
            .getUserToolLanguageFilterChangedPublisher()
            .receive(on: DispatchQueue.global())
            .map {
                return self.getToolFilterLanguage(appLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private func getToolFilterLanguage(appLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel {
        
        let languageId: String? = userToolFiltersRepository.getUserToolLanguageFilter()?.languageId
        
        if let languageId = languageId,
            let languageFilter = getToolFilterLanguage.getLanguageFilter(
                languageId: languageId,
                translatedInAppLanguage: appLanguage
            ) {
            
            return languageFilter
        }
        
        return getToolFilterLanguage.getAnyLanguageFilter(translatedInAppLanguage: appLanguage)
    }
}
