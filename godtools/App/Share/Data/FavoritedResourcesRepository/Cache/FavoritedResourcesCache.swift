//
//  FavoritedResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class FavoritedResourcesCache {
    
    private let persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>
    
    init(persistence: any Persistence<FavoritedResourceDataModel, FavoritedResourceDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, SwiftFavoritedResource>? {
        return persistence as? SwiftRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, SwiftFavoritedResource>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource>? {
        return persistence as? RealmRepositorySyncPersistence<FavoritedResourceDataModel, FavoritedResourceDataModel, RealmFavoritedResource>
    }
}
