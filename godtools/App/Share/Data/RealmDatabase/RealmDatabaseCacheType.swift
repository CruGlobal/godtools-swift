//
//  RealmDatabaseCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 11/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmDatabaseCacheType {
    
    case disk(fileName: String, migrationBlock: MigrationBlock)
    case inMemory(identifier: String)
}
