//
//  TestMigrationModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
typealias TestMigrationModel = TestMigrationModelSchemaV2.TestMigrationModel

@available(iOS 17, *)
enum TestMigrationModelSchemaV2: VersionedSchema {
 
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TestMigrationModel.self]
    }
    
    @Model
    class TestMigrationModel {
        
        var name: String = ""
        
        @Attribute(.unique) var email: String = ""
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17, *)
enum TestMigrationModelSchemaV1: VersionedSchema {
 
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TestMigrationModel.self]
    }
    
    @Model
    class TestMigrationModel {
        
        var email: String = ""
        var name: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
