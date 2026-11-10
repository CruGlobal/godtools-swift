//
//  GetPersonalizedToolResources.swift
//  godtools
//
//  Created by Jason Bennett on 11/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetPersonalizedToolResources: Sendable {

    private let personalizedToolsRepository: PersonalizedToolsRepository

    init(personalizedToolsRepository: PersonalizedToolsRepository) {

        self.personalizedToolsRepository = personalizedToolsRepository
    }

    func getRankedElseDefaultOrderTools(
        countryIsoRegionCode: String?,
        languageCode: String
    ) async throws -> [ResourceDataModel] {

        if let countryIsoRegionCode = countryIsoRegionCode {

            let rankedTools: [ResourceDataModel] = try await getToolResources(
                type: .ranked(country: countryIsoRegionCode, language: languageCode)
            )

            if !rankedTools.isEmpty {
                return rankedTools
            }
        }

        return try await getToolResources(
            type: .defaultOrder(language: languageCode)
        )
    }

    private func getToolResources(type: PersonalizedToolsType) async throws -> [ResourceDataModel] {

        return try await personalizedToolsRepository
            .getTools(
                requestPriority: .high,
                type: type,
                resourceTypes: ResourceType.toolTypes,
                sortByResponse: true
            )
            .filter { !$0.isHidden }
    }
}
