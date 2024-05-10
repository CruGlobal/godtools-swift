//
//  SyncInvalidator.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SyncInvalidator {
        
    private(set) var timeInterval: SyncInvalidatorTimeInterval
    private(set) var lastSync: Date?
    
    let id: String
    
    init(id: String, timeInterval: SyncInvalidatorTimeInterval) {
        
        self.id = id
        self.timeInterval = timeInterval
    }
    
    var shouldSync: Bool {
        
        let shouldSync: Bool
        
        if let lastSync = lastSync {
            
            let elapsedTimeInSeconds: TimeInterval = Date().timeIntervalSince(lastSync)
            let elapsedTimeInMinutes: TimeInterval = elapsedTimeInSeconds / 60
            
            switch timeInterval {
            case .minutes(let minute):
                shouldSync = elapsedTimeInMinutes >= minute
            }
        }
        else {
            
            shouldSync = true
        }
        
        if shouldSync {
            
            lastSync = Date()
        }
        
        return shouldSync
    }
    
    func setTimeInterval(timeInterval: SyncInvalidatorTimeInterval) {
        self.timeInterval = timeInterval
    }
}
