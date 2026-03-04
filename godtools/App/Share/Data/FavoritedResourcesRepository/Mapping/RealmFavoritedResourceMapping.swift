//
//  RealmFavoritedResourceMapping.swift
//  godtools
//
//  Created by Levi Eggert on 3/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmFavoritedResourceMapping: Mapping {
    
    func toDataModel(externalObject: FavoritedResourceDataModel) -> FavoritedResourceDataModel? {
        return FavoritedResourceDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmFavoritedResource) -> FavoritedResourceDataModel? {
        return FavoritedResourceDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: FavoritedResourceDataModel) -> RealmFavoritedResource? {
        return RealmFavoritedResource.createNewFrom(interface: externalObject)
    }
}
