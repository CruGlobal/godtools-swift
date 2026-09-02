//
//  GetPersonalizedLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedLessonFilterLanguagesUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let mapLanguageToPersonalizedLessonFilterLanguage: MapLanguageToPersonalizedLessonFilterLanguage
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        mapLanguageToPersonalizedLessonFilterLanguage: MapLanguageToPersonalizedLessonFilterLanguage
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.mapLanguageToPersonalizedLessonFilterLanguage = mapLanguageToPersonalizedLessonFilterLanguage
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<[PersonalizedLessonFilterLanguageDomainModel], Error> {
            
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (resourcesChanged: Void) -> AnyPublisher<[PersonalizedLessonFilterLanguageDomainModel], Error> in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [PersonalizedLessonFilterLanguageDomainModel] {
        
        let languageIds = self.resourcesRepository.getLessonsSupportedLanguageIds()
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)
        
        var domainModels: [PersonalizedLessonFilterLanguageDomainModel] = Array()

        for language in languages {

            let domainModel: PersonalizedLessonFilterLanguageDomainModel = self.mapLanguageToPersonalizedLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )

            domainModels.append(domainModel)
        }
        
        return domainModels
            .sorted { (language1: PersonalizedLessonFilterLanguageDomainModel, language2: PersonalizedLessonFilterLanguageDomainModel) in
                
                return language1.languageNamePair.nameInAppLanguage.lowercased() < language2.languageNamePair.nameInAppLanguage.lowercased()
            }
    }
}
