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
    @objc dynamic var latestCountFromAPI: Int = 0
    @objc dynamic var incrementValue: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: UserCounterDecodable) {
        
        id = model.id
        latestCountFromAPI = model.count
    }
}
