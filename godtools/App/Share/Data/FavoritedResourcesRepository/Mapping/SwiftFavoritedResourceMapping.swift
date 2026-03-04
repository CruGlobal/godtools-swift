//
//  SwiftFavoritedResourceMapping.swift
//  godtools
//
//  Created by Levi Eggert on 3/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftFavoritedResourceMapping: Mapping {
    
    func toDataModel(externalObject: FavoritedResourceDataModel) -> FavoritedResourceDataModel? {
        return FavoritedResourceDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftFavoritedResource) -> FavoritedResourceDataModel? {
        return FavoritedResourceDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: FavoritedResourceDataModel) -> SwiftFavoritedResource? {
        return SwiftFavoritedResource.createNewFrom(interface: externalObject)
    }
}
