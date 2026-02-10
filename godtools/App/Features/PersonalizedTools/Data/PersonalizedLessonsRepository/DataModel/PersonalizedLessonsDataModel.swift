//
//  PersonalizedLessonsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonsDataModel: PersonalizedLessonsDataModelInterface {

    let id: String
    let updatedAt: Date
    let resourceIds: [String]

    init(country: String, language: String, resourceIds: [String]) {
        self.id = PersonalizedLessonsId(country: country, language: language).value
        self.updatedAt = Date()
        self.resourceIds = resourceIds
    }

    init(interface: PersonalizedLessonsDataModelInterface) {
        self.id = interface.id
        self.updatedAt = interface.updatedAt
        self.resourceIds = interface.resourceIds
    }
}
