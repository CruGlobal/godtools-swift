//
//  UserToolSettingsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserToolSettingsDataModel {
    
    let createdAt: Date
    let toolId: String
    let primaryLanguageId: String
    let parallelLanguageId: String?
    
    init(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) {
        createdAt = Date()
        self.toolId = toolId
        self.primaryLanguageId = primaryLanguageId
        self.parallelLanguageId = parallelLanguageId
    }

    init(realmObject: RealmUserToolSettings) {
        createdAt = realmObject.createdAt
        toolId = realmObject.toolId
        primaryLanguageId = realmObject.primaryLanguageId
        parallelLanguageId = realmObject.parallelLanguageId
    }
}
