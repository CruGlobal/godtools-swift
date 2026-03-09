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

class RealmPersonalizedTools: Object, IdentifiableRealmObject, PersonalizedToolsDataModelInterface {

    @objc dynamic var id: String = ""
    @objc dynamic var updatedAt: Date = Date()

    let resourceIds = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    func getResourceIds() -> [String] {
        return Array(resourceIds)
    }

    func mapFrom(interface: PersonalizedToolsDataModelInterface) {
        id = interface.id
        updatedAt = interface.updatedAt
        resourceIds.removeAll()
        resourceIds.append(objectsIn: interface.getResourceIds())
    }

    static func createNewFrom(interface: PersonalizedToolsDataModelInterface) -> RealmPersonalizedTools {
        let object = RealmPersonalizedTools()
        object.mapFrom(interface: interface)
        return object
    }
}
