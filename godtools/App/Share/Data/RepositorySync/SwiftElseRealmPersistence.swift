//
//  SwiftElseRealmPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

// TODO: This class can be removed once RealmSwift is removed in place of SwiftData for iOS 17 minimum and up. ~Levi
open class SwiftElseRealmPersistence<DataModelType, ExternalObjectType, RealmObjectType: IdentifiableRealmObject> {
    
    private let realmDatabase: RealmDatabase
    private let realmDataModelMapping: any RepositorySyncMapping<DataModelType, ExternalObjectType, RealmObjectType>
    
    init(realmDatabase: RealmDatabase, realmDataModelMapping: any RepositorySyncMapping<DataModelType, ExternalObjectType, RealmObjectType>) {
        
        self.realmDatabase = realmDatabase
        self.realmDataModelMapping = realmDataModelMapping
    }
    
    func getPersistence() -> any RepositorySyncPersistence<DataModelType, ExternalObjectType> {
        
        if #available(iOS 17, *),
           let swiftDatabase = getSwiftDatabase(),
           let swiftPersistence = getAnySwiftPersistence(swiftDatabase: swiftDatabase) {
            
            return swiftPersistence
        }
        else {
            
            return RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType>(
                realmDatabase: realmDatabase,
                dataModelMapping: realmDataModelMapping
            )
        }
    }

    @available(iOS 17, *)
    func getSwiftDatabase() -> SwiftDatabase? {
        return TempSharedSwiftDatabase.shared.swiftDatabase
    }
    
    @available(iOS 17, *)
    func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<DataModelType, ExternalObjectType>)? {
        // NOTE: Subclasses should override and return a SwiftRepositorySyncPersistence. ~Levi
        return nil
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType> {
        
        return RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType>(
            realmDatabase: realmDatabase,
            dataModelMapping: realmDataModelMapping
        )
    }
}
