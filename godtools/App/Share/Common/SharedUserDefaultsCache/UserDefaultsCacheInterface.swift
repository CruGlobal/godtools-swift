//
//  UserDefaultsCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol UserDefaultsCacheInterface: SyncInvalidatorPersistenceInterface {
    
    func deleteValue(key: String)
    func getValue(key: String) -> Any?
    func cache(value: Any?, forKey: String)
    func commitChanges()
}

// MARK: - SyncInvalidatorPersistenceInterface

extension UserDefaultsCacheInterface {
    
    func getDate(id: String) -> Date? {
        return getValue(key: id) as? Date
    }
    
    func saveDate(id: String, date: Date?) {
        cache(value: date, forKey: id)
        commitChanges()
    }
    
    func deleteDate(id: String) {
        deleteValue(key: id)
    }
}
