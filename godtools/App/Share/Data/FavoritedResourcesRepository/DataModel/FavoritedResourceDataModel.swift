//
//  FavoritedResourceDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct FavoritedResourceDataModel: Sendable {
    
    let id: String
    let createdAt: Date
    let position: Int
    
    func copy(position: Int) -> FavoritedResourceDataModel {
        
        return FavoritedResourceDataModel(
            id: id,
            createdAt: createdAt,
            position: position
        )
    }
}
