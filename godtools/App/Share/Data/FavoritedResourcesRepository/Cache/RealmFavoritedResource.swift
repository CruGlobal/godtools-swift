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

class RealmFavoritedResource: Object, IdentifiableRealmObject, FavoritedResourceDataModelInterface {
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var id: String = ""
    @objc dynamic var resourceId: String = ""
    @objc dynamic var position: Int = 0
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
    
    func mapFrom(interface: FavoritedResourceDataModelInterface) {
        
        createdAt = interface.createdAt
        id = interface.id
        resourceId = interface.id
        position = interface.position
    }
    
    static func createNewFrom(interface: FavoritedResourceDataModelInterface) -> RealmFavoritedResource {
        let object = RealmFavoritedResource()
        object.mapFrom(interface: interface)
        return object
    }
}
