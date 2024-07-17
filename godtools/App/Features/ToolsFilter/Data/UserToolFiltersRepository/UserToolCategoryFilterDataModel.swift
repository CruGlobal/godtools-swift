//
//  UserToolCategoryFilterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserToolCategoryFilterDataModel {
    
    let createdAt: Date
    let categoryId: String
    
    init(realmUserToolCategoryFilter: RealmUserToolCategoryFilter) {
        
        createdAt = realmUserToolCategoryFilter.createdAt
        categoryId = realmUserToolCategoryFilter.categoryId
    }
}
