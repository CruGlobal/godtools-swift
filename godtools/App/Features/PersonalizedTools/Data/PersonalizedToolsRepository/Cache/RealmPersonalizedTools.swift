//
//  RealmPersonalizedTools.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmPersonalizedTools: Object, IdentifiableRealmObject {

    @objc dynamic var id: String = ""
    @objc dynamic var updatedAt: Date = Date()

    let resourceIds = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmPersonalizedTools {
    
    func mapFrom(model: PersonalizedToolsDataModel) {
        id = model.id
        updatedAt = model.updatedAt
        resourceIds.removeAll()
        resourceIds.append(objectsIn: model.resourceIds)
    }

    static func createNewFrom(model: PersonalizedToolsDataModel) -> RealmPersonalizedTools {
        let object = RealmPersonalizedTools()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> PersonalizedToolsDataModel {
        return PersonalizedToolsDataModel(
            id: id,
            updatedAt: updatedAt,
            resourceIds: getResourceIds()
        )
    }
    
    func getResourceIds() -> [String] {
        return Array(resourceIds)
    }
}
