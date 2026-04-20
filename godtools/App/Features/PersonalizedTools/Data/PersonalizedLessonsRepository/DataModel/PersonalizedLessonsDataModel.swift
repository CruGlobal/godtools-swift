//
//  PersonalizedLessonsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonsDataModel {

    let id: String
    let updatedAt: Date
    let resourceIds: [String]
    
    static func createFromCountry(country: String?, language: String, resourceIds: [String]) throws -> PersonalizedLessonsDataModel {
        
        let type = PersonalizedLessonsType(country: country, language: language)
        
        return PersonalizedLessonsDataModel(
            id: try PersonalizedLessonsId(type: type).value,
            updatedAt: Date(),
            resourceIds: resourceIds
        )
    }
}
