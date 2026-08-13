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
            .flatMap {
                
                return AnyPublisher() {
                    return await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async -> ToolFilterLanguageDomainModel {
        
        let languageId: String? = userToolFiltersRepository.getUserToolLanguageFilter()?.languageId
        
        if let languageId = languageId,
            let languageFilter = await getToolFilterLanguage.getLanguageFilter(
                languageId: languageId,
                translatedInAppLanguage: appLanguage
            ) {
            
            return languageFilter
        }
        
        return await getToolFilterLanguage.getAnyLanguageFilter(translatedInAppLanguage: appLanguage)
    }
}
