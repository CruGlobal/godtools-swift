//
//  GetToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterLanguagesUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getToolFilterLanguage: GetToolFilterLanguage
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        getToolFilterLanguage: GetToolFilterLanguage
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getToolFilterLanguage = getToolFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, filteredByCategory: ToolFilterCategoryDomainModel) -> AnyPublisher<[ToolFilterLanguageDomainModel], Error> {
        
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { _ in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage, filteredByCategory: filteredByCategory)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel, filteredByCategory: ToolFilterCategoryDomainModel) async throws -> [ToolFilterLanguageDomainModel] {
        
        let languageIds = resourcesRepository
            .getAllToolLanguageIds(filteredByCategoryId: filteredByCategory.filterId)
        
        let filteredByCategoryId: String? = filteredByCategory.filterId
        
        let anyLanguage = getToolFilterLanguage.createAnyLanguageDomainModel(
            translatedInAppLanguage: appLanguage,
            filteredByCategoryId: filteredByCategoryId
        )

        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)

        var domainModels: [ToolFilterLanguageDomainModel] = Array()

        for language in languages {

            let domainModel: ToolFilterLanguageDomainModel = getToolFilterLanguage.createLanguageFilterDomainModel(
                language: language,
                translatedInAppLanguage: appLanguage,
                filteredByCategoryId: filteredByCategoryId
            )

            guard domainModel.toolsAvailableCount > 0 else {
                continue
            }

            domainModels.append(domainModel)
        }
        
        let sortedDomainModels: [ToolFilterLanguageDomainModel] = domainModels
            .sorted { (thisLanguage: ToolFilterLanguageDomainModel, thatLanguage: ToolFilterLanguageDomainModel) in
                
                let thisLanguageName: String = thisLanguage.languageNamePair.nameInAppLanguage
                let thatLanguageName: String = thatLanguage.languageNamePair.nameInAppLanguage
                
                return thisLanguageName.lowercased() < thatLanguageName.lowercased()
            }
        
        return [anyLanguage] + sortedDomainModels
    }
}
