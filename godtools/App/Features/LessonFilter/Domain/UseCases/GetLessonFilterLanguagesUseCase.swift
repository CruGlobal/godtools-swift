//
//  ViewLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLessonFilterLanguagesUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getLessonFilterLangauge: GetLessonFilterLanguage
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        getLessonFilterLangauge: GetLessonFilterLanguage
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getLessonFilterLangauge = getLessonFilterLangauge
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error> {
            
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (resourcesChanged: Void) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error> in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [LessonFilterLanguageDomainModel] {
        
        let languageIds = self.resourcesRepository.getLessonsSupportedLanguageIds()
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)
        
        var domainModels: [LessonFilterLanguageDomainModel] = Array()

        for language in languages {

            let domainModel: LessonFilterLanguageDomainModel = await self.getLessonFilterLangauge.mapLanguageToLessonFilterLanguageDomainModel(
                language: language,
                translatedInAppLanguage: appLanguage
            )

            guard domainModel.lessonsAvailableCount > 0 else {
                continue
            }

            domainModels.append(domainModel)
        }
        
        return domainModels
            .sorted { (language1: LessonFilterLanguageDomainModel, language2: LessonFilterLanguageDomainModel) in
                
                return language1.languageNameTranslatedInAppLanguage.lowercased() < language2.languageNameTranslatedInAppLanguage.lowercased()
            }
    }
}
