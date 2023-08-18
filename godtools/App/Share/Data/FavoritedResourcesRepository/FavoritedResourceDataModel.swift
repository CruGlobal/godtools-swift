//
//  FavoritedResourceDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct FavoritedResourceDataModel {
    
    let createdAt: Date
    let id: String
    
    init(id: String) {
        
        self.createdAt = Date()
        self.id = id
    }
    
    init(realmFavoritedResource: RealmFavoritedResource) {
        
        self.createdAt = realmFavoritedResource.createdAt
        self.id = realmFavoritedResource.resourceId
    }
}
