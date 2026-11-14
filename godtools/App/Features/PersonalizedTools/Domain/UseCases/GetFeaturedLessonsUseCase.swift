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
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let languagesRepository: LanguagesRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonListItemProgress: GetLessonListItemProgress

    init(
        resourcesRepository: ResourcesRepository,
        personalizedToolsRepository: PersonalizedToolsRepository,
        languagesRepository: LanguagesRepository,
        getLanguageElseAppLanguage: GetLanguageElseAppLanguage,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability,
        lessonProgressRepository: UserLessonProgressRepository,
        getLessonListItemProgress: GetLessonListItemProgress
    ) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.languagesRepository = languagesRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonListItemProgress = getLessonListItemProgress
    }

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguageId: String?) -> AnyPublisher<[FeaturedLessonDomainModel], Error> {

        guard let countryIsoRegionCode = country?.isoRegionCodeIfSelected else {

            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let languageCode: String = getLanguageElseAppLanguage
            .getLanguageCode(
                languageId: filterLessonsByLanguageId,
                appLanguage: appLanguage
            )

        return Publishers.CombineLatest3(
            personalizedToolsRepository
                .getPersonalizedToolsChanged(
                    requestPriority: .high,
                    country: countryIsoRegionCode,
                    language: languageCode
                ),
            resourcesRepository
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap({ (personalizedToolsChanged: Void, resourcesChanged: Void, lessonProgressDidChange: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Error> in

            return AnyPublisher() {
                try await self.asyncExecute(
                    appLanguage: appLanguage,
                    countryIsoRegionCode: countryIsoRegionCode,
                    languageCode: languageCode,
                    filterLessonsByLanguageId: filterLessonsByLanguageId
                )
            }
        })
        .eraseToAnyPublisher()
    }

    private func asyncExecute(appLanguage: AppLanguageDomainModel, countryIsoRegionCode: String, languageCode: String, filterLessonsByLanguageId: String?) async throws -> [FeaturedLessonDomainModel] {

        let lessonLanguageModel: LanguageDataModel? = getLanguageElseAppLanguage.getLanguage(languageId: filterLessonsByLanguageId, appLanguage: appLanguage)

        let featuredLessonsDataModels: [ResourceDataModel] = try await personalizedToolsRepository
            .getTools(
                requestPriority: .high,
                type: .featured(country: countryIsoRegionCode, language: languageCode),
                resourceTypes: [.lesson],
                sortByResponse: true
            )
            .filter { !$0.isHidden }

        var featuredLessons: [FeaturedLessonDomainModel] = Array()

        for resource in featuredLessonsDataModels {

            let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel

            if let language = lessonLanguageModel {
                toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: appLanguage)
            }
            else {
                toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
            }

            let lessonProgress = try self.getLessonListItemProgress.getLessonProgress(
                lesson: resource,
                appLanguage: appLanguage
            )

            let nameLanguageDirection: LanguageDirectionDomainModel

            if let lessonLanguageModel = lessonLanguageModel {
                nameLanguageDirection = lessonLanguageModel.languageDirectionDomainModel
            } else {
                nameLanguageDirection = .leftToRight
            }

            featuredLessons.append(
                FeaturedLessonDomainModel(
                    analyticsToolName: resource.abbreviation,
                    availabilityInAppLanguage: toolLanguageAvailability,
                    bannerImageId: resource.attrBanner,
                    dataModelId: resource.id,
                    name: self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: lessonLanguageModel?.code ?? appLanguage),
                    nameLanguageDirection: nameLanguageDirection,
                    lessonProgress: lessonProgress
                )
            )
        }

        return featuredLessons
    }
}
