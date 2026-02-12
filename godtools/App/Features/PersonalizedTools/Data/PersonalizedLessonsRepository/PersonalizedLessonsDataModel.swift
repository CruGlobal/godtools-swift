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

    init(country: String?, language: String, resourceIds: [String]) {
        self.id = RealmPersonalizedLessons.createId(country: country, language: language)
        self.updatedAt = Date()
        self.resourceIds = resourceIds
    }

    init(realmObject: RealmPersonalizedLessons) {
        self.id = realmObject.id
        self.updatedAt = realmObject.updatedAt
        self.resourceIds = realmObject.getResourceIds()
    }
}
