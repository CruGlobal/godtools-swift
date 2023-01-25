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
                
                let realmGlobalAnalytics: RealmGlobalAnalytics = realm.object(ofType: RealmGlobalAnalytics.self, forPrimaryKey: globalAnalytics.id) ?? RealmGlobalAnalytics()
                
                realmGlobalAnalytics.countries = globalAnalytics.countries
                realmGlobalAnalytics.createdAt = Date()
                realmGlobalAnalytics.id = globalAnalytics.id
                realmGlobalAnalytics.gospelPresentations = globalAnalytics.gospelPresentations
                realmGlobalAnalytics.launches = globalAnalytics.launches
                realmGlobalAnalytics.type = globalAnalytics.type
                realmGlobalAnalytics.users = globalAnalytics.users
                                                                
                do {
                    
                    try realm.write {
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
