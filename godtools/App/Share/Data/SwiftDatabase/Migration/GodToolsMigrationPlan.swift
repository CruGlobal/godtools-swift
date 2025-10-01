//
//  GodToolsMigrationPlan.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftData

@available(iOS 17, *)
class GodToolsMigrationPlan: SchemaMigrationPlan, SwiftDatabaseMigrationPlanInterface {
    
    static var schemas: [any VersionedSchema.Type] {
        return [TestMigrationModelSchemaV1.self, TestMigrationModelSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        return [migrateTestMigrationModelV1ToV2]
    }
    
    var migrationPlan: (any SchemaMigrationPlan.Type)? {
        return GodToolsMigrationPlan.self
    }
    
    private static let migrateTestMigrationModelV1ToV2 = MigrationStage.custom(
        fromVersion: TestMigrationModelSchemaV1.self,
        toVersion: TestMigrationModelSchemaV2.self,
        willMigrate: { (context: ModelContext) in
            
            print("\n ***** Running GodToolsMigrationPlan *****")
            
            let existingObjects: [TestMigrationModel]
            
            do {
                existingObjects = try context.fetch(
                    FetchDescriptor<TestMigrationModel>()
                )
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                existingObjects = Array()
            }
                        
            for object in existingObjects {
                
                let id: String = object.id
                let email: String = "email_\(id)"
                
                object.email = email
                
                context.insert(object)
            }

            do {
                try context.save()
            }
            catch let error {
                assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
            }
            
        },
        didMigrate: nil
    )
}
