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
    
    func execute(
        appLanguage: AppLanguageDomainModel,
        country: LocalizationSettingsCountryDomainModel?,
        languageFilterLanguageId: String?
    ) async throws {
        
        let requestPriority: RequestPriority = .high
        
        _ = try await resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments(
            requestPriority: requestPriority,
            forceFetchFromRemote: true
        )

        let language: String = getLanguageElseAppLanguage.getLanguageCode(
            languageId: languageFilterLanguageId,
            appLanguage: appLanguage
        )
        
        let country: String? = country?.isoRegionCode
        
        try await personalizedToolsSync.sync(
            requestPriority: requestPriority,
            country: country,
            language: language,
            forceNewSync: true
        )
    }
}
