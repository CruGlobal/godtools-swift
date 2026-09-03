//
//  GetPersonalizedToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetPersonalizedToolFilterLanguagesUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let mapLanguageToPersonalizedToolFilterLanguage: MapLanguageToPersonalizedToolFilterLanguage
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        mapLanguageToPersonalizedToolFilterLanguage: MapLanguageToPersonalizedToolFilterLanguage
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.mapLanguageToPersonalizedToolFilterLanguage = mapLanguageToPersonalizedToolFilterLanguage
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<[PersonalizedToolFilterLanguageDomainModel], Error> {
            
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (resourcesChanged: Void) -> AnyPublisher<[PersonalizedToolFilterLanguageDomainModel], Error> in
                
                return AnyPublisher() {
                    try await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [PersonalizedToolFilterLanguageDomainModel] {
        
        let languageIds = self.resourcesRepository.getAllToolLanguageIds(filteredByCategoryId: nil)
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(ids: languageIds)
        
        var domainModels: [PersonalizedToolFilterLanguageDomainModel] = Array()

        for language in languages {

            let domainModel: PersonalizedToolFilterLanguageDomainModel = self.mapLanguageToPersonalizedToolFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )

            domainModels.append(domainModel)
        }
        
        return domainModels
            .sorted { (language1: PersonalizedToolFilterLanguageDomainModel, language2: PersonalizedToolFilterLanguageDomainModel) in
                
                return language1.languageNamePair.nameInAppLanguage.lowercased() < language2.languageNamePair.nameInAppLanguage.lowercased()
            }
    }
}
