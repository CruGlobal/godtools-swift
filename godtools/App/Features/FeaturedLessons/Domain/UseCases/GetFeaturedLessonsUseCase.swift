//
//  GetFeaturedLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetFeaturedLessonsUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonListItemProgress: GetLessonListItemProgress
    
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability,
        lessonProgressRepository: UserLessonProgressRepository,
        getLessonListItemProgress: GetLessonListItemProgress
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonListItemProgress = getLessonListItemProgress
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Error> {
                    
        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap({ (resourcesChanged: Void, lessonProgressDidChange: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Error> in
            
            return AnyPublisher() {
                try await self.asyncExecute(appLanguage: appLanguage)
            }
        })
        .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [FeaturedLessonDomainModel] {
        
        let appLanguageModel: LanguageDataModel? = languagesRepository.getLanguageByCode(code: appLanguage)
        
        let featuredLessonsDataModels: [ResourceDataModel] = try await resourcesRepository
            .getFeaturedLessons(sorted: true)
        
        var featuredLessons: [FeaturedLessonDomainModel] = Array()

        for resource in featuredLessonsDataModels {

            let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel

            if let language = appLanguageModel {
                toolLanguageAvailability = await self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: language)
            }
            else {
                toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
            }

            let lessonProgress = try await self.getLessonListItemProgress.getLessonProgress(
                lesson: resource,
                appLanguage: appLanguage
            )

            let nameLanguageDirection: LanguageDirectionDomainModel

            if let filterLanguageModel = appLanguageModel {
                nameLanguageDirection = filterLanguageModel.languageDirectionDomainModel
            } else {
                nameLanguageDirection = .leftToRight
            }

            featuredLessons.append(
                FeaturedLessonDomainModel(
                    analyticsToolName: resource.abbreviation,
                    availabilityInAppLanguage: toolLanguageAvailability,
                    bannerImageId: resource.attrBanner,
                    dataModelId: resource.id,
                    name: self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage),
                    nameLanguageDirection: nameLanguageDirection,
                    lessonProgress: lessonProgress
                )
            )
        }

        return featuredLessons
    }
}
