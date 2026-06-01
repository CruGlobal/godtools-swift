//
//  RealmMigrationInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmMigrationInterface: Sendable {
    
    var shouldMigrate: Bool { get }
    
    init(oldSchemaVersion: UInt64)
    
    func migrate(migration: Migration)
}
