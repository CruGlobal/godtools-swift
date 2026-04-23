//
//  SwiftFavoritedResource.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftFavoritedResource = SwiftFavoritedResourceV1.SwiftFavoritedResource

@available(iOS 17.4, *)
enum SwiftFavoritedResourceV1 {

    @Model
    class SwiftFavoritedResource: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var position: Int = 0
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var resourceId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftFavoritedResource {
    
    func mapFrom(model: FavoritedResourceDataModel) {
        
        createdAt = model.createdAt
        id = model.id
        resourceId = model.id
        position = model.position
    }
    
    static func createNewFrom(model: FavoritedResourceDataModel) -> SwiftFavoritedResource {
        let object = SwiftFavoritedResource()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> FavoritedResourceDataModel {
        return FavoritedResourceDataModel(
            id: id,
            createdAt: createdAt,
            position: position
        )
    }
}
