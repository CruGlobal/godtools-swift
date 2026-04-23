//
//  GlobalAnalyticsCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class GlobalAnalyticsCache {
    
    let persistence: any Persistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable>
    
    init(persistence: any Persistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable, SwiftGlobalAnalytics>? {
        return persistence as? SwiftRepositorySyncPersistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable, SwiftGlobalAnalytics>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable, RealmGlobalAnalytics>? {
        return persistence as? RealmRepositorySyncPersistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable, RealmGlobalAnalytics>
    }
}
