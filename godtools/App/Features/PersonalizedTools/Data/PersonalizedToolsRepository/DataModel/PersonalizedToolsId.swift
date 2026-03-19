//
//  PersonalizedToolsId.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolsId: Sendable {

    let value: String

    private init(value: String) {
        self.value = value
    }

    init(type: PersonalizedToolsType) throws {

        switch type {

        case .allRanked(let country, let language):
            value = try PersonalizedToolsId.createForAllRankedTools(country: country, language: language).value

        case .defaultOrder(let language):
            value = PersonalizedToolsId.createForDefaultOrder(language: language).value
        }
    }

    static func createForAllRankedTools(country: String, language: String) throws -> PersonalizedToolsId {

        guard !country.isEmpty else {
            throw NSError.errorWithDescription(description: "Country cannot be empty.")
        }

        return PersonalizedToolsId(value: "\(country)_\(language)")
    }

    static func createForDefaultOrder(language: String) -> PersonalizedToolsId {

        return PersonalizedToolsId(value: language)
    }
}
