//
//  SyncInvalidatorManager.swift
//  godtools
//
//  Created by Levi Eggert on 5/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SyncInvalidatorManager {
    
    typealias ManagerId = String
    typealias SyncInvalidatorId = String
    
    private static let defaultManagerId: ManagerId = "default_sync_invalidator_manager"
    
    private static var managers: [ManagerId: [SyncInvalidatorId: SyncInvalidator]] = Dictionary()
        
    static func getInvalidator(managerId: ManagerId = SyncInvalidatorManager.defaultManagerId, id: SyncInvalidatorId, timeInterval: SyncInvalidatorTimeInterval) -> SyncInvalidator {
        
        let syncInvalidator: SyncInvalidator
        
        if let existingSyncInvalidator = managers[managerId]?[id] {
            syncInvalidator = existingSyncInvalidator
        }
        else {
            syncInvalidator = SyncInvalidator(id: id, timeInterval: timeInterval)
        }

        syncInvalidator.setTimeInterval(timeInterval: timeInterval)
        
        addSyncInvalidator(managerId: managerId, syncInvalidator: syncInvalidator)
                
        return syncInvalidator
    }
    
    private static func addSyncInvalidator(managerId: ManagerId = SyncInvalidatorManager.defaultManagerId, syncInvalidator: SyncInvalidator) {
        
        var manager: [SyncInvalidatorId: SyncInvalidator] = managers[managerId] ?? Dictionary()
        
        manager[syncInvalidator.id] = syncInvalidator
        
        managers[managerId] = manager
    }
}
