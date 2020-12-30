//
//  FavoritedResourceModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FavoritedResourceModel: FavoritedResourceModelType {
    
    let resourceId: String
    let sortOrder: Int
    
    init(model: FavoritedResourceModelType) {
        
        resourceId = model.resourceId
        sortOrder = model.sortOrder
    }
}
