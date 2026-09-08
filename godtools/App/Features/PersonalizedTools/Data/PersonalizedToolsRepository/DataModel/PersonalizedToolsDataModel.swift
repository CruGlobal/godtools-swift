//
//  PersonalizedToolsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolsDataModel: Sendable {

    let id: String
    let resourceIds: [String]
    let updatedAt: Date
    
    init(type: PersonalizedToolsType, resourceIds: [String]) throws {
        
        self.id = try PersonalizedToolsId(type: type).value
        self.resourceIds = resourceIds
        self.updatedAt = Date()
    }
    
    init(id: String, resourceIds: [String], updatedAt: Date) {
        
        self.id = id
        self.resourceIds = resourceIds
        self.updatedAt = updatedAt
    }
}
