//
//  MockSyncInvalidatorPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockSyncInvalidatorPersistence: SyncInvalidatorPersistenceInterface {
   
    private var storedDates: [String: Date] = Dictionary()
    
    init() {
        
    }
    
    func getDate(id: String) -> Date? {
        return storedDates[id]
    }
    
    func saveDate(id: String, date: Date?) {
        storedDates[id] = date
    }
    
    func deleteDate(id: String) {
        storedDates[id] = nil
    }
}
