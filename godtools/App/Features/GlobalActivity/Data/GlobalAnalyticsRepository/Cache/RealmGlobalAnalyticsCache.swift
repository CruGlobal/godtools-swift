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
                
                return self.getGlobalAnalytics(id: id)
            }
            .eraseToAnyPublisher()
    }
    
    private func getGlobalAnalytics(id: String) -> GlobalAnalyticsDataModel? {
        
        let realmObject: RealmGlobalAnalytics? = realmDatabase.readObject(primaryKey: id)
        
        let dataModel: GlobalAnalyticsDataModel?
        
        if let realmObject = realmObject {
            
            dataModel = GlobalAnalyticsDataModel(realmGlobalAnalytics: realmObject)
        }
        else {
            
            dataModel = nil
        }
        
        return dataModel
    }
    
    func storeGlobalAnalyticsPublisher(globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> AnyPublisher<GlobalAnalyticsDataModel, Error> {
        
        return realmDatabase.writeObjectsPublisher(shouldAddObjectsToRealm: true) { (realm: Realm) in
            
            let realmGlobalAnalytics: RealmGlobalAnalytics = RealmGlobalAnalytics()
            
            realmGlobalAnalytics.mapFrom(decodable: globalAnalytics)
            
            return [realmGlobalAnalytics]
        }
        .map { _ in
            return GlobalAnalyticsDataModel(mobileContentAnalyticsDecodable: globalAnalytics)
        }
        .eraseToAnyPublisher()
    }
}
