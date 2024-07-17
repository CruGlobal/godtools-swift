//
//  UserToolLanguageFilterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserToolLanguageFilterDataModel {
    
    let createdAt: Date
    let languageId: String
    
    init(realmUserToolLanguageFilter: RealmUserToolLanguageFilter) {
        
        createdAt = realmUserToolLanguageFilter.createdAt
        languageId = realmUserToolLanguageFilter.languageId
    }
}
