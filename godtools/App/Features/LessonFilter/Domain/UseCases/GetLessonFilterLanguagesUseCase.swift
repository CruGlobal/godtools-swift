//
//  ViewLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLessonFilterLanguagesUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let mapLanguageToLessonFilterLanguage: MapLanguageToLessonFilterLanguage
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        mapLanguageToLessonFilterLanguage: MapLanguageToLessonFilterLanguage
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.mapLanguageToLessonFilterLanguage = mapLanguageToLessonFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolLanguageFilterItemDomainModel], Error> {
            
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (resourcesChanged: Void) -> AnyPublisher<[ToolLanguageFilterItemDomainModel], Error> in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [ToolLanguageFilterItemDomainModel] {
        
        let languageIds = self.resourcesRepository.getLessonsSupportedLanguageIds()
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)
        
        var domainModels: [ToolLanguageFilterItemDomainModel] = Array()

        for language in languages {

            let domainModel: ToolLanguageFilterItemDomainModel = self.mapLanguageToLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )

            guard let lessonsAvailableCount = domainModel.availableCount, lessonsAvailableCount > 0 else {
                continue
            }

            domainModels.append(domainModel)
        }
        
        return domainModels
            .sorted { (language1: ToolLanguageFilterItemDomainModel, language2: ToolLanguageFilterItemDomainModel) in
                
                return language1.languageNameTranslatedInAppLanguage.lowercased() < language2.languageNameTranslatedInAppLanguage.lowercased()
            }
    }
}
