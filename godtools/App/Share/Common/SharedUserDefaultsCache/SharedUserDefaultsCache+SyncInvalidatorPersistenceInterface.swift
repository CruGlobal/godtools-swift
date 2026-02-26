//
//  SharedUserDefaultsCache+SyncInvalidatorPersistenceInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension SharedUserDefaultsCache: SyncInvalidatorPersistenceInterface {
    
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
