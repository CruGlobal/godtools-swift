//
//  SwiftDatabaseMigrationPlanInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftData

@available(iOS 17, *)
protocol SwiftDatabaseMigrationPlanInterface {
    
    var migrationPlan: (any SchemaMigrationPlan.Type)? { get }
}
