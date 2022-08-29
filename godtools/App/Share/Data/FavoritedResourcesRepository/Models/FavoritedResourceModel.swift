//
//  FavoritedResourceModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FavoritedResourceModel: FavoritedResourceModelType {
    
    let createdAt: Date
    let resourceId: String
    
    init(resourceId: String) {
        
        createdAt = Date()
        self.resourceId = resourceId
    }
    
    init(model: FavoritedResourceModelType) {
        
        createdAt = model.createdAt
        resourceId = model.resourceId
    }
}
