//
//  RealmPersonalizedLessons.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmPersonalizedLessons: Object, IdentifiableRealmObject {

    @objc dynamic var id: String = ""
    @objc dynamic var updatedAt: Date = Date()

    let resourceIds = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmPersonalizedLessons {
    
    func mapFrom(model: PersonalizedLessonsDataModel) {
        id = model.id
        updatedAt = model.updatedAt
        resourceIds.removeAll()
        resourceIds.append(objectsIn: model.resourceIds)
    }
    
    static func createNewFrom(model: PersonalizedLessonsDataModel) -> RealmPersonalizedLessons {
        let object = RealmPersonalizedLessons()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> PersonalizedLessonsDataModel {
        return PersonalizedLessonsDataModel(
            id: id,
            updatedAt: updatedAt,
            resourceIds: getResourceIds()
        )
    }
    
    func getResourceIds() -> [String] {
        return Array(resourceIds)
    }
}
