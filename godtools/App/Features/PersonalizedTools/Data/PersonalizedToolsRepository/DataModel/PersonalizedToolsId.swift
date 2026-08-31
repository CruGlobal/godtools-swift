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
            
        case .defaultOrder(let language):
            value = try PersonalizedToolsId.createForDefaultOrder(language: language).value
            
        case .featured(let country, let language):
            value = try PersonalizedToolsId.createForFeatured(country: country, language: language).value
            
        case .ranked(let country, let language):
            value = try PersonalizedToolsId.createForRanked(country: country, language: language).value
        }
    }
    
    static func createForDefaultOrder(language: String) throws -> PersonalizedToolsId {

        guard !language.isEmpty else {
            throw NSError.errorWithDescription(description: "Language cannot be empty.")
        }
        
        return PersonalizedToolsId(value: "default_order_\(language)")
    }
    
    static func createForFeatured(country: String, language: String) throws -> PersonalizedToolsId {

        guard !country.isEmpty else {
            throw NSError.errorWithDescription(description: "Country cannot be empty.")
        }
        
        guard !language.isEmpty else {
            throw NSError.errorWithDescription(description: "Language cannot be empty.")
        }

        return PersonalizedToolsId(value: "featured_\(country)_\(language)")
    }

    static func createForRanked(country: String, language: String) throws -> PersonalizedToolsId {

        guard !country.isEmpty else {
            throw NSError.errorWithDescription(description: "Country cannot be empty.")
        }
        
        guard !language.isEmpty else {
            throw NSError.errorWithDescription(description: "Language cannot be empty.")
        }

        return PersonalizedToolsId(value: "ranked_\(country)_\(language)")
    }
}
