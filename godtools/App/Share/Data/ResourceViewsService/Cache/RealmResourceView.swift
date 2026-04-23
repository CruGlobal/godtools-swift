//
//  RealmResourceView.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmResourceView: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var resourceId: String = ""
    @objc dynamic var quantity: Int = 0
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}

extension RealmResourceView {
    
    func mapFrom(model: ResourceViewsDataModel) {
        id = model.id
        resourceId = model.resourceId
        quantity = model.quantity
    }
    
    static func createNewFrom(model: ResourceViewsDataModel) -> RealmResourceView {
        let object = RealmResourceView()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ResourceViewsDataModel {
        return ResourceViewsDataModel(
            id: id,
            resourceId: resourceId,
            quantity: quantity
        )
    }
}
