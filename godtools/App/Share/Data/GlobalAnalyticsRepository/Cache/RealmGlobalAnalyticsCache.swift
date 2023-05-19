//
//  RealmGlobalAnalyticsCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmGlobalAnalyticsCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getGlobalAnalyticsChangedPublisher(id: String) -> AnyPublisher<GlobalAnalyticsDataModel?, Never> {
        
        return realmDatabase.openRealm().objects(RealmGlobalAnalytics.self).objectWillChange
            .map { _ in
                
                let realmObject: RealmGlobalAnalytics? = self.realmDatabase.readObject(primaryKey: id)
                
                if let realmObject = realmObject {
                    return GlobalAnalyticsDataModel(realmGlobalAnalytics: realmObject)
                }
                
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    func storeGlobalAnalyticsPublisher(globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> AnyPublisher<GlobalAnalyticsDataModel, Error> {
        
        return realmDatabase.updateObjectsPublisher(shouldAddObjectsToRealm: true) { (realm: Realm) in
            
            let realmGlobalAnalytics: RealmGlobalAnalytics = self.createAndMapRealmGlobalAnalyticsObject(globalAnalytics: globalAnalytics)
            
            return [realmGlobalAnalytics]
        }
        .map { _ in
            return GlobalAnalyticsDataModel(mobileContentAnalyticsDecodable: globalAnalytics)
        }
        .eraseToAnyPublisher()
    }
    
    private func createAndMapRealmGlobalAnalyticsObject(globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> RealmGlobalAnalytics {
        
        let realmGlobalAnalytics: RealmGlobalAnalytics
        let existingGlobalAnalytics: RealmGlobalAnalytics? = realmDatabase.readObject(primaryKey: globalAnalytics.id)
        let shouldMapId: Bool
        
        if let existingGlobalAnalytics = existingGlobalAnalytics {
            
            realmGlobalAnalytics = existingGlobalAnalytics
            shouldMapId = false
        }
        else {
            
            realmGlobalAnalytics = RealmGlobalAnalytics()
            shouldMapId = true
        }
                    
        realmGlobalAnalytics.mapFrom(decodable: globalAnalytics, shouldMapId: shouldMapId)
        
        return realmGlobalAnalytics
    }
}
