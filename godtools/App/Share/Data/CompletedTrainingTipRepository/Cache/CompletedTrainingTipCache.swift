//
//  CompletedTrainingTipCache.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class CompletedTrainingTipCache {
    
    let persistence: any Persistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel>
    
    init(persistence: any Persistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, SwiftCompletedTrainingTip>? {
        return persistence as? SwiftRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, SwiftCompletedTrainingTip>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, RealmCompletedTrainingTip>? {
        return persistence as? RealmRepositorySyncPersistence<CompletedTrainingTipDataModel, CompletedTrainingTipDataModel, RealmCompletedTrainingTip>
    }
}
