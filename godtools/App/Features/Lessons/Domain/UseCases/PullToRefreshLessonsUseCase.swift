//
//  PullToRefreshLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class PullToRefreshLessonsUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsSync: PersonalizedToolsSync
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage

    init(
        resourcesRepository: ResourcesRepository,
        personalizedToolsSync: PersonalizedToolsSync,
        getLanguageElseAppLanguage: GetLanguageElseAppLanguage
    ) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsSync = personalizedToolsSync
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
    }
    
    func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) async throws {
        
        let requestPriority: RequestPriority = .high
        
        _ = try await resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments(
            requestPriority: requestPriority,
            forceFetchFromRemote: true
        )

        try await refreshPersonalizedLessons(
            requestPriority: requestPriority,
            appLanguage: appLanguage,
            country: country,
            filterLessonsByLanguage: filterLessonsByLanguage
        )
    }
    
    
    private func refreshPersonalizedLessons(requestPriority: RequestPriority, appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) async throws {

        let languageCode: String = getLanguageElseAppLanguage.getLanguageCode(
            languageId: filterLessonsByLanguage?.languageId,
            appLanguage: appLanguage
        )

        let countryIsoRegionCode: String? = {
            if let isoRegionCode = country?.isoRegionCode, !isoRegionCode.isEmpty {
                return isoRegionCode
            }
            return nil
        }()
        
        _ = try await personalizedToolsSync
            .syncPersonalizedTools(
                requestPriority: requestPriority,
                country: countryIsoRegionCode,
                language: languageCode,
                forceNewSync: true
            )
    }
}
