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
    
    func getGlobalAnalytics(id: String) -> RealmGlobalAnalytics? {
        
        return realmDatabase.openRealm().object(ofType: RealmGlobalAnalytics.self, forPrimaryKey: id)
    }
    
    func getGlobalAnalyticsChangedPublisher(id: String) -> AnyPublisher<RealmGlobalAnalytics?, Never> {
        return realmDatabase.openRealm().objects(RealmGlobalAnalytics.self).objectWillChange
            .map {
                return self.realmDatabase.openRealm().object(ofType: RealmGlobalAnalytics.self, forPrimaryKey: id)
            }
            .eraseToAnyPublisher()
    }
    
    func storeGlobalAnalyticsPublisher(globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> AnyPublisher<MobileContentGlobalAnalyticsDecodable, Error> {
        
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                let realmGlobalAnalytics: RealmGlobalAnalytics
                
                if let existingRealmGlobalAnalytics = realm.object(ofType: RealmGlobalAnalytics.self, forPrimaryKey: globalAnalytics.id) {
                   
                    realmGlobalAnalytics = existingRealmGlobalAnalytics
                }
                else {
                    
                    let newRealmGlobalAnalytics = RealmGlobalAnalytics()
                    
                    newRealmGlobalAnalytics.id = globalAnalytics.id
                    
                    realmGlobalAnalytics = newRealmGlobalAnalytics
                }
                
                do {
                    
                    try realm.write {
                        
                        realmGlobalAnalytics.mapFrom(decodable: globalAnalytics)
                        
                        realm.add(realmGlobalAnalytics, update: .all)
                    }
                    
                    promise(.success(globalAnalytics))
                }
                catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
