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
    class SwiftFavoritedResource: IdentifiableSwiftDataObject, FavoritedResourceDataModelInterface {
        
        var createdAt: Date = Date()
        var position: Int = 0
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var resourceId: String = ""
        
        init() {
            
        }
        
        func mapFrom(interface: FavoritedResourceDataModelInterface) {
            
            createdAt = interface.createdAt
            id = interface.id
            resourceId = interface.id
            position = interface.position
        }
        
        static func createNewFrom(interface: FavoritedResourceDataModelInterface) -> SwiftFavoritedResource {
            let object = SwiftFavoritedResource()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
