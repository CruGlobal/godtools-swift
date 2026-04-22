//
//  GlobalAnalyticsCacheObject.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmGlobalAnalytics: Object, IdentifiableRealmObject {
    
    @objc dynamic var countries: Int = 0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var gospelPresentations: Int = 0
    @objc dynamic var id: String = ""
    @objc dynamic var launches: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var users: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmGlobalAnalytics {
 
    func mapFrom(model: GlobalAnalyticsDataModel) {
        
        countries = model.countries
        createdAt = model.createdAt
        gospelPresentations = model.gospelPresentations
        id = model.id
        launches = model.launches
        type = model.type
        users = model.users
    }
    
    static func createNewFrom(model: GlobalAnalyticsDataModel) -> RealmGlobalAnalytics {
        
        let object = RealmGlobalAnalytics()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> GlobalAnalyticsDataModel {
        return GlobalAnalyticsDataModel(
            id: id,
            createdAt: createdAt,
            countries: countries,
            gospelPresentations: gospelPresentations,
            launches: launches,
            users: users,
            type: type
        )
    }
}
