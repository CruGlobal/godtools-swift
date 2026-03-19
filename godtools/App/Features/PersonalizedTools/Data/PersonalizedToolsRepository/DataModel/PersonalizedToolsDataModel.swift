//
//  PersonalizedToolsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolsDataModel: PersonalizedToolsDataModelInterface {

    let id: String
    let updatedAt: Date
    let resourceIds: [String]

    init(country: String?, language: String, resourceIds: [String]) throws {

        let type = PersonalizedToolsType(country: country, language: language)

        self.id = try PersonalizedToolsId(type: type).value

        self.updatedAt = Date()
        self.resourceIds = resourceIds
    }

    init(interface: PersonalizedToolsDataModelInterface) {
        self.id = interface.id
        self.updatedAt = interface.updatedAt
        self.resourceIds = interface.getResourceIds()
    }

    func getResourceIds() -> [String] {
        return resourceIds
    }
}
