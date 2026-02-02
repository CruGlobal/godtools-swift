//
//  SyncInvalidator.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

public final class SyncInvalidator {
    
    private let id: String
    private let timeInterval: SyncInvalidatorTimeInterval
    private let persistence: SyncInvalidatorPersistenceInterface
    
    public init(id: String, timeInterval: SyncInvalidatorTimeInterval, persistence: SyncInvalidatorPersistenceInterface) {
        
        self.id = id
        self.timeInterval = timeInterval
        self.persistence = persistence
    }
    
    private var keyLastSyncDate: String {
        return String(describing: SyncInvalidator.self) + ".keyLastSyncDate.\(id)"
    }
    
    public var shouldSync: Bool {
        
        let shouldSync: Bool
        
        if let lastSync = getLastSyncDate() {
            
            let elapsedTimeInSeconds: TimeInterval = Date().timeIntervalSince(lastSync)
            let elapsedTimeInMinutes: TimeInterval = elapsedTimeInSeconds / 60
            let elapsedTimeInHours: TimeInterval = elapsedTimeInMinutes / 60
            let elapsedTimeInDays: TimeInterval = elapsedTimeInHours / 24
            
            switch timeInterval {
            case .minutes(let minute):
                shouldSync = elapsedTimeInMinutes >= minute
            case .hours(let hour):
                shouldSync = elapsedTimeInHours >= hour
            case .days(let day):
                shouldSync = elapsedTimeInDays >= day
            }
        }
        else {
            
            shouldSync = true
        }
        
        return shouldSync
    }
    
    public func didSync(lastSyncDate: Date = Date()) {
        storeLastSyncDate(date: lastSyncDate)
    }
    
    public func resetSync() {
        persistence.deleteDate(id: keyLastSyncDate)
    }
    
    private func getLastSyncDate() -> Date? {
        return persistence.getDate(id: keyLastSyncDate)
    }
    
    private func storeLastSyncDate(date: Date) {
        persistence.saveDate(id: keyLastSyncDate, date: date)
    }
}
