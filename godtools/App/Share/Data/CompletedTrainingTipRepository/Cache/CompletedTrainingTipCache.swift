//
//  CompletedTrainingTipCache.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

final class CompletedTrainingTipCache {
    
    let persistence: any Persistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel>
    
    init(persistence: any Persistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, SwiftCompletedTrainingTip>? {
        return persistence as? SwiftRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, SwiftCompletedTrainingTip>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, RealmCompletedTrainingTip>? {
        return persistence as? RealmRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, RealmCompletedTrainingTip>
    }
}

extension CompletedTrainingTipCache {
    /*
    func getCompletedTrainingTip(id: String) throws -> CompletedTrainingTipDataModel? {
        
        return try getRealmPersistence()?.getDataModel(id: id)
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
        
    }*/
}
