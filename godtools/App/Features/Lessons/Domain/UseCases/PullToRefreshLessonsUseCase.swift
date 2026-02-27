//
//  PullToRefreshLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

final class PullToRefreshLessonsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let personalizedLessonsRepository: PersonalizedLessonsRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    
    init(resourcesRepository: ResourcesRepository, personalizedLessonsRepository: PersonalizedLessonsRepository, getLanguageElseAppLanguage: GetLanguageElseAppLanguage) {
        
        self.resourcesRepository = resourcesRepository
        self.personalizedLessonsRepository = personalizedLessonsRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
    }
    
    func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<Void, Error> {
        
        let requestPriority: RequestPriority = .high
        
        return Publishers.Merge(
            refreshResources(requestPriority: requestPriority),
            refreshPersonalizedLessons(
                requestPriority: requestPriority,
                appLanguage: appLanguage,
                country: country,
                filterLessonsByLanguage: filterLessonsByLanguage
            )
        )
        .eraseToAnyPublisher()
    }
    
    private func refreshResources(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(
                requestPriority: requestPriority,
                forceFetchFromRemote: true
            )
            .map { _ in
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    private func refreshPersonalizedLessons(requestPriority: RequestPriority, appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<Void, Error> {
        
        let languageCode: String = getLanguageElseAppLanguage.getLanguageCode(
            languageId: filterLessonsByLanguage?.languageId,
            appLanguage: appLanguage
        )
        
        let countryIsoRegionCode: String? = country?.isoRegionCode
        
        // TODO: Remove this guard once supporting an optional country in this UseCase. ~Levi
        guard let countryIsoRegionCode = countryIsoRegionCode, !countryIsoRegionCode.isEmpty else {
            return Just(Void())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return personalizedLessonsRepository
            .syncAllRankedLessonsPublisher(
                requestPriority: requestPriority,
                country: countryIsoRegionCode,
                language: languageCode,
                forceNewSync: true
            )
            .map { _ in
                return ()
            }
            .eraseToAnyPublisher()
    }
}
