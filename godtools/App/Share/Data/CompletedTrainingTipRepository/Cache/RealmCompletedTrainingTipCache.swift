//
//  RealmCompletedTrainingTipCache.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class RealmCompletedTrainingTipCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getCompletedTrainingTip(id: String) -> CompletedTrainingTipDataModel? {
        
        guard let realmCompletedTrainingTip = realmDatabase.openRealm().object(ofType: RealmCompletedTrainingTip.self, forPrimaryKey: id) else {
            return nil
        }
        
        return realmCompletedTrainingTip.toModel()
    }
        
    func countCompletedTrainingTips() -> Int {
        
        return realmDatabase.openRealm().objects(RealmCompletedTrainingTip.self).count
    }
    
    func storeCompletedTrainingTip(completedTrainingTip: CompletedTrainingTipDataModel) -> AnyPublisher<CompletedTrainingTipDataModel, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let realmCompletedTrainingTip = RealmCompletedTrainingTip.createNewFrom(model: completedTrainingTip)
                
                do {
                    
                    try realm.write {
                        realm.add(realmCompletedTrainingTip, update: .modified)
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
