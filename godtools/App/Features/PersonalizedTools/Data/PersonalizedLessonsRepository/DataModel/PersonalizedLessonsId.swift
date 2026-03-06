//
//  PersonalizedLessonsId.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonsId: Sendable {

    let value: String
    
    private init(value: String) {
        self.value = value
    }
    
    init(type: PersonalizedLessonsType) throws {
        
        switch type {
        
        case .allRanked(let country, let language):
            value = try PersonalizedLessonsId.createForAllRankedLessons(country: country, language: language).value
            
        case .defaultOrder(let language):
            value = PersonalizedLessonsId.createForDefaultOrder(language: language).value
        }
    }
    
    static func createForAllRankedLessons(country: String, language: String) throws -> PersonalizedLessonsId {
        
        guard !country.isEmpty else {
            throw NSError.errorWithDescription(description: "Country cannot be empty.")
        }
        
        return PersonalizedLessonsId(value: "\(country)_\(language)")
    }
    
    static func createForDefaultOrder(language: String) -> PersonalizedLessonsId {
        
        return PersonalizedLessonsId(value: language)
    }
}
