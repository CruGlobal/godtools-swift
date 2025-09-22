//
//  SharedSwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

// TODO: GT-2753 Can be removed and moved to AppDataLayerDependencies once RealmSwift is removed and supporting iOS 17 and up. ~Levi
@available(iOS 17, *)
class SharedSwiftDatabase {
    
    static let shared: SharedSwiftDatabase = SharedSwiftDatabase()
    
    let swiftDatabase: SwiftDatabase = SwiftDatabase(
        configuration: SwiftDatabaseProductionConfiguration(),
        modelTypes: GodToolsSwiftDataModelTypes()
    )
    
    private init() {
        
    }
}
