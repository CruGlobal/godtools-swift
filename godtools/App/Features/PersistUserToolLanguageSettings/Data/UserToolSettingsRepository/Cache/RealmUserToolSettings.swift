//
//  RealmUserToolSettings.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserToolSettings: Object {
    
    @Persisted var createdAt: Date = Date()
    @Persisted var toolId: String = ""
    @Persisted var primaryLanguageId: String = ""
    @Persisted var parallelLanguageId: String?
    
    override static func primaryKey() -> String? {
        return "toolId"
    }
    
    func mapFrom(dataModel: UserToolSettingsDataModel) {
        
        createdAt = dataModel.createdAt
        toolId = dataModel.toolId
        primaryLanguageId = dataModel.primaryLanguageId
        parallelLanguageId = dataModel.parallelLanguageId
    }
}
