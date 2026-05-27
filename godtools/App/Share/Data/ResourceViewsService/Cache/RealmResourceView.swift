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
    @objc dynamic var resourceId: String = "" {
        didSet {
            id = resourceId
        }
    }
    @objc dynamic var quantity: Int = 0
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}

extension RealmResourceView {
    
    func mapFrom(model: ResourceViewDataModel) {
        id = model.id
        resourceId = model.resourceId
        quantity = model.quantity
    }
    
    static func createNewFrom(model: ResourceViewDataModel) -> RealmResourceView {
        let object = RealmResourceView()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ResourceViewDataModel {
        return ResourceViewDataModel(
            id: id,
            resourceId: resourceId,
            quantity: quantity
        )
    }
}
