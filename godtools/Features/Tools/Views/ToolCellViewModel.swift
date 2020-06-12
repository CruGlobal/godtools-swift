//
//  ToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolCellViewModel: ToolCellViewModelType {
    
    let title: String
    let description: String
    let isFavorited: Bool
    
    required init(resource: RealmResource, favoritedResourcesCache: RealmFavoritedResourcesCache) {
        
        title = resource.name
        description = resource.attrCategory
        isFavorited = favoritedResourcesCache.isFavorited(resourceId: resource.id)
    }
}
