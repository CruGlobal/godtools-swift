//
//  SyncInvalidatorPersistenceInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

public protocol SyncInvalidatorPersistenceInterface {
    
    func getDate(id: String) -> Date?
    func saveDate(id: String, date: Date?)
    func deleteDate(id: String)
}
