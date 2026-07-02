//
//  RealmLocalActivityCount.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmLocalActivityCount: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var count: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmLocalActivityCount {
    
    func mapFrom(model: LocalActivityCountDataModel) {
        id = model.id
        count = model.count
    }
    
    static func createNewFrom(model: LocalActivityCountDataModel) -> RealmLocalActivityCount {
        let object = RealmLocalActivityCount()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> LocalActivityCountDataModel {
        return LocalActivityCountDataModel(
            id: id,
            count: count
        )
    }
}
