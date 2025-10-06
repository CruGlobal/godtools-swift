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
typealias TestMigrationModel = TestMigrationModelV2.TestMigrationModel

@available(iOS 17, *)
enum TestMigrationModelV2 {
    
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
enum TestMigrationModelV1 {
    
    @Model
    class TestMigrationModel {
        
        var email: String = ""
        var name: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
