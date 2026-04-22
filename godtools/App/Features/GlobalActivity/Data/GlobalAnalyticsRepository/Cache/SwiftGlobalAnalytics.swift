//
//  SwiftGlobalAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftGlobalAnalytics = SwiftGlobalAnalyticsV1.SwiftGlobalAnalytics

@available(iOS 17.4, *)
enum SwiftGlobalAnalyticsV1 {
 
    @Model
    class SwiftGlobalAnalytics: IdentifiableSwiftDataObject {
        
        var countries: Int = 0
        var createdAt: Date = Date()
        var gospelPresentations: Int = 0
        var launches: Int = 0
        var type: String = ""
        var users: Int = 0
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftGlobalAnalytics {
    
    func mapFrom(model: GlobalAnalyticsDataModel) {
        
        countries = model.countries
        createdAt = model.createdAt
        gospelPresentations = model.gospelPresentations
        id = model.id
        launches = model.launches
        type = model.type
        users = model.users
    }
    
    static func createNewFrom(model: GlobalAnalyticsDataModel) -> SwiftGlobalAnalytics {
        
        let object = SwiftGlobalAnalytics()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftGlobalAnalytics {
 
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
