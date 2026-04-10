//
//  PullToRefreshToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

final class PullToRefreshToolsUseCase {

    private let resourcesRepository: ResourcesRepository
    private let personalizedToolsRepository: PersonalizedToolsRepository
    private let getLanguageElseAppLanguage: GetLanguageElseAppLanguage

    init(resourcesRepository: ResourcesRepository, personalizedToolsRepository: PersonalizedToolsRepository, getLanguageElseAppLanguage: GetLanguageElseAppLanguage) {

        self.resourcesRepository = resourcesRepository
        self.personalizedToolsRepository = personalizedToolsRepository
        self.getLanguageElseAppLanguage = getLanguageElseAppLanguage
    }

    func execute(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterToolsByLanguage: ToolFilterLanguageDomainModel?) -> AnyPublisher<Void, Error> {

        let requestPriority: RequestPriority = .high

        return Publishers.Merge(
            refreshResources(requestPriority: requestPriority),
            refreshPersonalizedTools(
                requestPriority: requestPriority,
                appLanguage: appLanguage,
                country: country,
                filterToolsByLanguage: filterToolsByLanguage
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
    
    private func refreshPersonalizedTools(requestPriority: RequestPriority, appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterToolsByLanguage: ToolFilterLanguageDomainModel?) -> AnyPublisher<Void, Error> {

        let languageCode: String = getLanguageElseAppLanguage.getLanguageCode(
            languageId: filterToolsByLanguage?.languageDataModelId,
            appLanguage: appLanguage
        )

        let countryIsoRegionCode: String? = {
            if let isoRegionCode = country?.isoRegionCode, !isoRegionCode.isEmpty {
                return isoRegionCode
            }
            return nil
        }()

        return personalizedToolsRepository
            .syncPersonalizedToolsPublisher(
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
