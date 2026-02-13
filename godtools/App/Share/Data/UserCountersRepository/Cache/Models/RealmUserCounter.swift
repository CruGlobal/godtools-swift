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
    @objc dynamic var latestCountFromAPI: Int = 0
    @objc dynamic var incrementValue: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(codable: UserCounterDecodable) {
        id = codable.id
        latestCountFromAPI = codable.count
    }
    
    func mapFrom(interface: UserCounterDataModelInterface) {
        id = interface.id
        latestCountFromAPI = interface.latestCountFromAPI
        incrementValue = interface.incrementValue
    }
    
    static func createNewFrom(interface: UserCounterDataModelInterface) -> RealmUserCounter {
        let object = RealmUserCounter()
        object.mapFrom(interface: interface)
        return object
    }
}
