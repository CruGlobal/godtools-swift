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

final class RealmGlobalAnalyticsCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    @MainActor func getGlobalAnalyticsChangedPublisher(id: String) -> AnyPublisher<GlobalAnalyticsDataModel?, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmGlobalAnalytics.self)
            .objectWillChange
            .map { _ in
                
                return self.getGlobalAnalytics(id: id)
            }
            .eraseToAnyPublisher()
    }
    
    private func getGlobalAnalytics(id: String) -> GlobalAnalyticsDataModel? {
        
        let realmObject: RealmGlobalAnalytics? = realmDatabase.readObject(primaryKey: id)
        
        let dataModel: GlobalAnalyticsDataModel?
        
        if let realmObject = realmObject {
            
            dataModel = realmObject.toModel()
        }
        else {
            
            dataModel = nil
        }
        
        return dataModel
    }
    
    func storeGlobalAnalyticsPublisher(globalAnalytics: MobileContentGlobalAnalyticsCodable) -> AnyPublisher<GlobalAnalyticsDataModel, Error> {
        
        let dataModel: GlobalAnalyticsDataModel = globalAnalytics.toModel()
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmGlobalAnalytics] in
            
            let realmGlobalAnalytics = RealmGlobalAnalytics.createNewFrom(model: dataModel)
            
            return [realmGlobalAnalytics]
            
        } mapInBackgroundClosure: { (objects: [RealmGlobalAnalytics]) -> [GlobalAnalyticsDataModel] in
            return objects.map({
                $0.toModel()
            })
        }
        .map { _ in
            return dataModel
        }
        .eraseToAnyPublisher()
    }
}
