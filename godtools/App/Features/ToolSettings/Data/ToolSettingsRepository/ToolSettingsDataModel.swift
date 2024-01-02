//
//  ToolSettingsDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsDataModel {
    
    let id: String
    let parallelLanguageId: String?
    let primaryLanguageId: String?
    
    init(realmToolSettings: RealmToolSettings) {
        
        self.id = realmToolSettings.id
        self.parallelLanguageId = realmToolSettings.parallelLanguageId
        self.primaryLanguageId = realmToolSettings.primaryLanguageId
    }
}
