//
//  RealmCompletedTrainingTipCache.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class RealmCompletedTrainingTipCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getCompletedTrainingTip(id: String) -> CompletedTrainingTipDataModel? {
        
        guard let realmCompletedTrainingTip = realmDatabase.openRealm().object(ofType: RealmCompletedTrainingTip.self, forPrimaryKey: id) else { return nil }
        
        return CompletedTrainingTipDataModel(realmCompletedTrainingTip: realmCompletedTrainingTip)
    }
        
    func countCompletedTrainingTips() -> Int {
        
        return realmDatabase.openRealm().objects(RealmCompletedTrainingTip.self).count
    }
    
    func storeCompletedTrainingTip(completedTrainingTip: CompletedTrainingTipDataModel) -> AnyPublisher<CompletedTrainingTipDataModel, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let realmCompletedTrainingTip = RealmCompletedTrainingTip()
                realmCompletedTrainingTip.mapFrom(model: completedTrainingTip)
                
                do {
                    
                    try realm.write {
                        realm.add(realmCompletedTrainingTip, update: .all)
                    }
                    
                    promise(.success(completedTrainingTip))
                }
                catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
}
