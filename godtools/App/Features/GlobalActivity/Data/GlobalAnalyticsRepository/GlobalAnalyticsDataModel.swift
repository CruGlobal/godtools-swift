//
//  GlobalAnalyticsDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct GlobalAnalyticsDataModel {
    
    let countries: Int
    let gospelPresentations: Int
    let launches: Int
    let users: Int
    
    init(mobileContentAnalyticsDecodable: MobileContentGlobalAnalyticsDecodable) {
        
        countries = mobileContentAnalyticsDecodable.countries
        gospelPresentations = mobileContentAnalyticsDecodable.gospelPresentations
        launches = mobileContentAnalyticsDecodable.launches
        users = mobileContentAnalyticsDecodable.users
    }
    
    init(realmGlobalAnalytics: RealmGlobalAnalytics) {
        
        countries = realmGlobalAnalytics.countries
        gospelPresentations = realmGlobalAnalytics.gospelPresentations
        launches = realmGlobalAnalytics.launches
        users = realmGlobalAnalytics.users
    }
}
