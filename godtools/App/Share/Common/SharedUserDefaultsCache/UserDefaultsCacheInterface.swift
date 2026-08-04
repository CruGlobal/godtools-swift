//
//  UserDefaultsCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol UserDefaultsCacheInterface: Actor, SyncInvalidatorPersistenceInterface {
    
    func getBool(key: String) -> Bool?
    func storeBool(value: Bool?, forKey: String)
    func getDate(key: String) -> Date?
    func storeDate(value: Date?, forKey: String)
    func getInt(key: String) -> Int?
    func storeInt(value: Int?, forKey: String)
    func getString(key: String) -> String?
    func storeString(value: String?, forKey: String)
    func deleteValue(key: String)
    func commitChanges()
}

// MARK: - SyncInvalidatorPersistenceInterface

extension UserDefaultsCacheInterface {
    
    func getDate(id: String) -> Date? {
        return getDate(key: id)
    }
    
    func saveDate(id: String, date: Date?) {
        storeDate(value: date, forKey: id)
        commitChanges()
    }
    
    func deleteDate(id: String) {
        deleteValue(key: id)
    }
}
