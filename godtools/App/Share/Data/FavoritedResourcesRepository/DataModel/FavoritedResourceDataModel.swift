//
//  FavoritedResourceDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct FavoritedResourceDataModel: FavoritedResourceDataModelInterface {
    
    let createdAt: Date
    let id: String
    let position: Int
    
    init(id: String, createdAt: Date = Date(), position: Int = 0) {
        
        self.createdAt = createdAt
        self.id = id
        self.position = position
    }
    
    init(interface: FavoritedResourceDataModelInterface) {
        
        self.createdAt = interface.createdAt
        self.id = interface.id
        self.position = interface.position
    }
    
    func copy(position: Int) -> FavoritedResourceDataModel {
        
        return FavoritedResourceDataModel(
            id: id,
            createdAt: createdAt,
            position: position
        )
    }
}
