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
        return [GodToolsSchemaV1.self, GodToolsSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        return [migrateTestMigrationModelV1ToV2]
    }
    
    var migrationPlan: (any SchemaMigrationPlan.Type)? {
        return GodToolsMigrationPlan.self
    }
        
    private static var v2Objects: [TestMigrationModelV2.TestMigrationModel] = Array()
    
    private static let migrateTestMigrationModelV1ToV2 = MigrationStage.custom(
        fromVersion: GodToolsSchemaV1.self,
        toVersion: GodToolsSchemaV2.self,
        willMigrate: { (context: ModelContext) in
            
            print("\n ***** Running GodToolsMigrationPlan *****")
            
            let version1Objects: [TestMigrationModelV1.TestMigrationModel]
            
            do {
                version1Objects = try context.fetch(
                    FetchDescriptor<TestMigrationModelV1.TestMigrationModel>()
                )
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                version1Objects = Array()
            }
            
            print("  has existing objects with ids: \(version1Objects.map {$0.id}) and emails: \(version1Objects.map {$0.email})")
                   
            var version2Objects: [TestMigrationModelV2.TestMigrationModel] = Array()
            var emailsAdded: Set<String> = Set()
            
            print("  adding v2 objects")
            
            for v1Object in version1Objects {
                
                guard !emailsAdded.contains(v1Object.email) else {
                    continue
                }
                
                emailsAdded.insert(v1Object.email)
                
                let v2Object = TestMigrationModelV2.TestMigrationModel()
                
                v2Object.email = v1Object.email
                v2Object.id = v1Object.id
                v2Object.name = v1Object.name
                                
                v2Objects.append(v2Object)
            }
            
            print("  created v2 objects with ids: \(version2Objects.map {$0.id}) and emails: \(version2Objects.map {$0.email})")

            
            print("deleting v1 objects...")
            
            for v1Object in version1Objects {
                context.delete(v1Object)
            }
            
            print("saving database")
            
            do {
                try context.save()
            }
            catch let error {
                assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
            }
            
            print("Finished Will Migrate")
        },
        didMigrate: { (context: ModelContext) in
            
            print("adding v2 objects to context...")
            
            for v2Object in v2Objects {
                
                context.insert(v2Object)
            }
            
            
            print("saving database")
            
            do {
                try context.save()
            }
            catch let error {
                assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
            }
            
            print("Finished Did Migrate")
        }
    )
}
