//
//  RealmUserCounter.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserCounter: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var count: Int = 0
    @objc dynamic var localCount: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmUserCounter {
    
    func mapFrom(model: UserCounterDataModel) {
        count = model.count
        id = model.id
    }
    
    static func createNewFrom(model: UserCounterDataModel) -> RealmUserCounter {
        let object = RealmUserCounter()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmUserCounter {
    
    func toModel() -> UserCounterDataModel {
        return UserCounterDataModel(
            id: id,
            count: count
        )
    }
}
