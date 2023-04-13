//
//  RealmDatabaseMockConfiguration.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class RealmDatabaseMockConfiguration: RealmDatabaseConfiguration {
    
    private static let inMemoryFileName = "godtools_realm_mock"
    private static let schemaVersion: UInt64 = 1
    
    init() {
        
        super.init(
            cacheType: .inMemory(identifier: RealmDatabaseMockConfiguration.inMemoryFileName),
            schemaVersion: RealmDatabaseMockConfiguration.schemaVersion
        )
    }
}
