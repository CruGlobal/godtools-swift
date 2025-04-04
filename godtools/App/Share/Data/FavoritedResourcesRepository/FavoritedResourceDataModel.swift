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
    let position: Int
    
    init(id: String) {
        
        self.createdAt = Date()
        self.id = id
        self.position = 0
    }
    
    init(id: String, createdAt: Date, position: Int) {
        
        self.createdAt = createdAt
        self.id = id
        self.position = position
    }
    
    init(realmFavoritedResource: RealmFavoritedResource) {
        
        self.createdAt = realmFavoritedResource.createdAt
        self.id = realmFavoritedResource.resourceId
        self.position = realmFavoritedResource.position
    }
}
