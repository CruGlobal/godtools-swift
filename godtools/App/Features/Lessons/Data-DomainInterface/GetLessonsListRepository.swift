//
//  GetLessonsListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsListRepository: GetLessonsListRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let getLessonListItemProgressRepository: GetLessonListItemProgressRepository

    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, getLessonListItemProgressRepository: GetLessonListItemProgressRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.getLessonListItemProgressRepository = getLessonListItemProgressRepository
    }
    
    @MainActor func getLessonsListPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {
                
        return Publishers.CombineLatest(
            resourcesRepository
                .persistence
                .observeCollectionChangesPublisher(),
            getLessonListItemProgressRepository
                .getLessonListItemProgressChanged()
                .setFailureType(to: Error.self)
        )
        .asyncMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) in
                        
            let lessons: [ResourceDataModel] = self.resourcesRepository.cache.getLessons(
                filterByLanguageId: filterLessonsByLanguage?.languageId,
                sorted: true
            )
            
            let filterLanguage: LanguageDataModel?
            
            if let filterLanguageId = filterLessonsByLanguage?.languageId {
                filterLanguage = try await self.languagesRepository.persistence.getDataModelsAsync(getOption: .object(id: filterLanguageId)).first
            }
            else {
                filterLanguage = nil
            }
            
            let lessonListItems: [LessonListItemDomainModel] = lessons.map { (resource: ResourceDataModel) in
                
                let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = self.getToolLanguageAvailability(
                    appLanguage: appLanguage,
                    filterLanguageModel: filterLanguage,
                    resource: resource
                )
                
                let lessonName: String = self.getTranslatedToolName.getToolName(
                    resource: resource,
                    translateInLanguage: filterLanguage?.code ?? appLanguage
                )
                
                let lessonProgress: LessonListItemProgressDomainModel = self.getLessonListItemProgressRepository.getLessonProgress(
                    lesson: resource,
                    appLanguage: appLanguage
                )
                
                let nameLanguageDirection: LanguageDirectionDomainModel
                
                if let filterLanguageModel = filterLanguage {
                    nameLanguageDirection = filterLanguageModel.languageDirectionDomainModel
                }
                else {
                    nameLanguageDirection = .leftToRight
                }
                
                return LessonListItemDomainModel(
                    analyticsToolName: resource.abbreviation,
                    availabilityInAppLanguage: toolLanguageAvailability,
                    bannerImageId: resource.attrBanner,
                    dataModelId: resource.id,
                    name: lessonName,
                    nameLanguageDirection: nameLanguageDirection,
                    lessonProgress: lessonProgress
                )
            }
            
            return lessonListItems
        })
        .eraseToAnyPublisher()
    }
}

extension GetLessonsListRepository {
    
    private func getToolLanguageAvailability(appLanguage: AppLanguageDomainModel, filterLanguageModel: LanguageDataModel?, resource: ResourceDataModel) async throws -> ToolLanguageAvailabilityDomainModel {

        let appLanguageModel: LanguageDataModel? = try await languagesRepository.cache.getCachedLanguage(code: appLanguage)
        
        guard let appLanguageModel = appLanguageModel else {
            return ToolLanguageAvailabilityDomainModel.empty
        }
        
        let language: LanguageDataModel
        
        if let filterLanguageModel = filterLanguageModel {
            language = filterLanguageModel
        } else {
            language = appLanguageModel
        }
        
        return self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
            resource: resource,
            language: language,
            translateInLanguage: appLanguageModel
        )
    }
}
