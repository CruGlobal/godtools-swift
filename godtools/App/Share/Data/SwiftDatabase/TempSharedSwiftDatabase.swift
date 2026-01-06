//
//  TempSharedSwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

// TODO: GT-2753 Can be removed and moved to AppDataLayerDependencies once RealmSwift is removed and supporting iOS 17 and up. ~Levi
@available(iOS 17.4, *)
class TempSharedSwiftDatabase {
        
    static let shared: TempSharedSwiftDatabase = TempSharedSwiftDatabase()
    
    private var database: SwiftDatabase?
    
    private init() {
        
    }
    
    func getDatabase() -> SwiftDatabase? {
        
        guard let database = self.database else {
            let productionDatabase = getProductionDatabase()
            self.database = productionDatabase
            return productionDatabase
        }
        
        return database
    }
    
    func setDatabase(swiftDatabase: SwiftDatabase) {
        self.database = swiftDatabase
    }
    
    private func getProductionDatabase() -> SwiftDatabase? {
        
        do {
            return SwiftDatabase(
                container: try SwiftDataProductionContainer().createContainer()
            )
        }
        catch let error {
            assertionFailure("Failed to create swift database")
            return nil
        }
    }
}
