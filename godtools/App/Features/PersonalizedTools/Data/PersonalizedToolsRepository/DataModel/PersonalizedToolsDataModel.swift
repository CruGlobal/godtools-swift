//
//  PersonalizedToolsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolsDataModel {

    let id: String
    let updatedAt: Date
    let resourceIds: [String]

    static func createFromCountry(country: String?, language: String, resourceIds: [String]) throws -> PersonalizedToolsDataModel {

        let type = PersonalizedToolsType(country: country, language: language)
        
        return PersonalizedToolsDataModel(
            id: try PersonalizedToolsId(type: type).value,
            updatedAt: Date(),
            resourceIds: resourceIds
        )
    }
}
