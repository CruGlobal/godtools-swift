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
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getLessonFilterLangauge: GetLessonFilterLanguage) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getLessonFilterLangauge = getLessonFilterLangauge
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error> {
            
        return resourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap { (resourcesChanged: Void) in
                
                let languageIds = self.resourcesRepository.cache.getLessonsSupportedLanguageIds()
                
                return self.createLessonLanguageFilterDomainModelListPublisher(from: languageIds, translatedInAppLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
}

extension GetLessonFilterLanguagesUseCase {
    
    private func createLessonLanguageFilterDomainModelListPublisher(from languageIds: [String], translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[LessonFilterLanguageDomainModel], Error> {
        
        return languagesRepository
            .persistence
            .getDataModelsPublisher(getOption: .objectsByIds(ids: languageIds))
            .map { (languages: [LanguageDataModel]) in
                
                let domainModels: [LessonFilterLanguageDomainModel] = languages.compactMap { (language: LanguageDataModel) in
                    
                    let domainModel: LessonFilterLanguageDomainModel = self.getLessonFilterLangauge.mapLanguageToLessonFilterLanguageDomainModel(
                        language: language,
                        translatedInAppLanguage: translatedInAppLanguage
                    )
                    
                    guard domainModel.lessonsAvailableCount > 0 else {
                        return nil
                    }
                    
                    return domainModel
                }
                
                return domainModels
                    .sorted { (language1: LessonFilterLanguageDomainModel, language2: LessonFilterLanguageDomainModel) in
                        
                        return language1.languageNameTranslatedInAppLanguage.lowercased() < language2.languageNameTranslatedInAppLanguage.lowercased()
                    }
            }
            .eraseToAnyPublisher()
    }
}
