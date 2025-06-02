//
//  SyncInvalidator.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class SyncInvalidator {
    
    private let id: String
    private let timeInterval: SyncInvalidatorTimeInterval
    private let userDefaultsCache: SharedUserDefaultsCache
    
    init(id: String, timeInterval: SyncInvalidatorTimeInterval, userDefaultsCache: SharedUserDefaultsCache) {
        
        self.id = id
        self.timeInterval = timeInterval
        self.userDefaultsCache = userDefaultsCache
    }
    
    private var keyLastSyncDate: String {
        return String(describing: SyncInvalidator.self) + ".keyLastSyncDate.\(id)"
    }
    
    var shouldSync: Bool {
        
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
    
    func didSync() {
        storeLastSyncDate(date: Date())
    }
    
    func resetSync() {
        userDefaultsCache.deleteValue(key: keyLastSyncDate)
        userDefaultsCache.commitChanges()
    }
    
    private func getLastSyncDate() -> Date? {
        return userDefaultsCache.getValue(key: keyLastSyncDate) as? Date
    }
    
    private func storeLastSyncDate(date: Date) {
        userDefaultsCache.cache(value: date, forKey: keyLastSyncDate)
        userDefaultsCache.commitChanges()
    }
}
