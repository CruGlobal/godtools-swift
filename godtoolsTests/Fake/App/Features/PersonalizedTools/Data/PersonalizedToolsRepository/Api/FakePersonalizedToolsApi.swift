//
//  FakePersonalizedToolsApi.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RequestOperation

struct FakePersonalizedToolsApi: PersonalizedToolsApiInterface {

    typealias PersonalizedToolsIdValue = String
    typealias ResourceId = String

    private let resourceIdsByPersonalizedToolsId: [PersonalizedToolsIdValue: [ResourceId]]

    init(resourceIdsByPersonalizedToolsId: [PersonalizedToolsIdValue: [ResourceId]]) {

        self.resourceIdsByPersonalizedToolsId = resourceIdsByPersonalizedToolsId
    }

    func getDefaultOrderResources(requestPriority: RequestPriority, language: TwoLetterLanguageCode, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable] {

        return try getResources(type: .defaultOrder(language: language))
    }

    func getFeaturedResources(requestPriority: RequestPriority, country: TwoLetterCountryCode, language: TwoLetterLanguageCode, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable] {

        return try getResources(type: .featured(country: country, language: language))
    }

    func getRankedResources(requestPriority: RequestPriority, country: TwoLetterCountryCode, language: TwoLetterLanguageCode, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable] {

        return try getResources(type: .ranked(country: country, language: language))
    }

    private func getResources(type: PersonalizedToolsType) throws -> [ResourceCodable] {

        let personalizedToolsId: PersonalizedToolsIdValue = try PersonalizedToolsId(type: type).value

        let resourceIds: [ResourceId] = resourceIdsByPersonalizedToolsId[personalizedToolsId] ?? Array()

        return resourceIds.map { (resourceId: ResourceId) in
            ResourceCodable(id: resourceId)
        }
    }
}
