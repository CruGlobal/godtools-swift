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

    @MainActor func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?) -> AnyPublisher<[FeaturedLessonDomainModel], Error> {

        guard let countryIsoRegionCode = getCountryIsoRegionCode(country: country) else {

            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap({ (resourcesChanged: Void, lessonProgressDidChange: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Error> in

            return AnyPublisher() {
                try await self.asyncExecute(appLanguage: appLanguage, countryIsoRegionCode: countryIsoRegionCode)
            }
        })
        .eraseToAnyPublisher()
    }

    private func getCountryIsoRegionCode(country: LocalizationSettingsCountryDomainModel?) -> String? {

        guard let isoRegionCode = country?.isoRegionCode, !isoRegionCode.isEmpty else {
            return nil
        }

        return isoRegionCode
    }

    private func asyncExecute(appLanguage: AppLanguageDomainModel, countryIsoRegionCode: String) async throws -> [FeaturedLessonDomainModel] {

        let appLanguageModel: LanguageDataModel? = languagesRepository.getLanguageByCode(code: appLanguage)

        // TODO: GT-3075 stubs this with spotlight lessons.  Replace with the leader-curated featured lessons for the
        // country and language pair, at which point countryIsoRegionCode should filter rather than only gate.
        let featuredLessonsDataModels: [ResourceDataModel] = try await resourcesRepository
            .getFeaturedLessons(sorted: true)

        var featuredLessons: [FeaturedLessonDomainModel] = Array()

        for resource in featuredLessonsDataModels {

            let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel

            if let language = appLanguageModel {
                toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: language)
            }
            else {
                toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
            }

            let lessonProgress = try self.getLessonListItemProgress.getLessonProgress(
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
