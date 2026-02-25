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

class RealmPersonalizedLessons: Object, IdentifiableRealmObject, PersonalizedLessonsDataModelInterface {

    @objc dynamic var id: String = ""
    @objc dynamic var updatedAt: Date = Date()

    let resourceIds = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    func getResourceIds() -> [String] {
        return Array(resourceIds)
    }

    func mapFrom(interface: PersonalizedLessonsDataModelInterface) {
        id = interface.id
        updatedAt = interface.updatedAt
        resourceIds.removeAll()
        resourceIds.append(objectsIn: interface.getResourceIds())
    }
    
    static func createNewFrom(interface: PersonalizedLessonsDataModelInterface) -> RealmPersonalizedLessons {
        let object = RealmPersonalizedLessons()
        object.mapFrom(interface: interface)
        return object
    }
}
