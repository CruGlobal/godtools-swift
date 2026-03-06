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

class RealmUserCounter: Object, IdentifiableRealmObject, UserCounterDataModelInterface {
    
    @objc dynamic var id: String = ""
    @objc dynamic var count: Int = 0
    @objc dynamic var localCount: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(interface: UserCounterDataModelInterface) {
        count = interface.count
        id = interface.id
    }
    
    static func createNewFrom(interface: UserCounterDataModelInterface) -> RealmUserCounter {
        let object = RealmUserCounter()
        object.mapFrom(interface: interface)
        return object
    }
}
