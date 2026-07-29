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

    func getAllRankedResources(requestPriority: RequestPriority, country: TwoLetterCountryCode?, language: TwoLetterLanguageCode?, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable] {

        return getResources(personalizedToolsId: "\(country ?? "")_\(language ?? "")")
    }

    func getDefaultOrderResources(requestPriority: RequestPriority, language: TwoLetterLanguageCode?, resourceTypes: [ResourceType]?) async throws -> [ResourceCodable] {

        return getResources(personalizedToolsId: language ?? "")
    }

    private func getResources(personalizedToolsId: PersonalizedToolsIdValue) -> [ResourceCodable] {

        let resourceIds: [ResourceId] = resourceIdsByPersonalizedToolsId[personalizedToolsId] ?? Array()

        return resourceIds.map { (resourceId: ResourceId) in
            ResourceCodable(id: resourceId)
        }
    }
}
