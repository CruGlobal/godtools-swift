//
//  PullToRefreshToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class PullToRefreshToolsUseCase: Sendable {

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
        filterToolsByLanguage: ToolFilterLanguageDomainModel
    ) async throws {

        let requestPriority: RequestPriority = .high
        
        _ = try await resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments(
                requestPriority: requestPriority,
                forceFetchFromRemote: true
            )
        
        try await refreshPersonalizedTools(
            requestPriority: requestPriority,
            appLanguage: appLanguage,
            country: country,
            filterToolsByLanguage: filterToolsByLanguage
        )
    }
    
    private func refreshPersonalizedTools(
        requestPriority: RequestPriority,
        appLanguage: AppLanguageDomainModel,
        country: LocalizationSettingsCountryDomainModel?,
        filterToolsByLanguage: ToolFilterLanguageDomainModel
    ) async throws {

        let languageCode: String = getLanguageElseAppLanguage.getLanguageCode(
            languageId: filterToolsByLanguage.filterId,
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
