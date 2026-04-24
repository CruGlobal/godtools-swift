//
//  RealmFavoritedResource.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmFavoritedResource: Object, IdentifiableRealmObject {
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var resourceId: String = ""
    @objc dynamic var position: Int = 0
    
    @objc dynamic var id: String {
        get {
            return resourceId
        }
        set {
            resourceId = newValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}

extension RealmFavoritedResource {
    
    func mapFrom(model: FavoritedResourceDataModel) {
        
        createdAt = model.createdAt
        id = model.id
        resourceId = model.id
        position = model.position
    }
    
    static func createNewFrom(model: FavoritedResourceDataModel) -> RealmFavoritedResource {
        let object = RealmFavoritedResource()
        object.mapFrom(model: model)
        return object
    }
    
    static func createNewFrom(realmResource: RealmFavoritedResource) -> RealmFavoritedResource {
        
        let object = RealmFavoritedResource()
        
        object.createdAt = realmResource.createdAt
        object.id = realmResource.id
        object.resourceId = realmResource.id
        object.position = realmResource.position
        
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
