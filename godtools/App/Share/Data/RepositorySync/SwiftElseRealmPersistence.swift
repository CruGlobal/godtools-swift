//
//  SwiftElseRealmPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

// TODO: This class can be removed once RealmSwift is removed in place of SwiftData for iOS 17 minimum and up. ~Levi
open class SwiftElseRealmPersistence<DataModelType, ExternalObjectType, RealmObjectType: IdentifiableRealmObject> {
    
    private let realmDatabase: RealmDatabase
    private let realmDataModelMapping: any Mapping<DataModelType, ExternalObjectType, RealmObjectType>
    
    let swiftPersistenceIsEnabled: Bool
    
    init(realmDatabase: RealmDatabase, realmDataModelMapping: any Mapping<DataModelType, ExternalObjectType, RealmObjectType>, swiftPersistenceIsEnabled: Bool?) {
        
        self.realmDatabase = realmDatabase
        self.realmDataModelMapping = realmDataModelMapping
        self.swiftPersistenceIsEnabled = false
    }
    
    func getPersistence() -> any Persistence<DataModelType, ExternalObjectType> {
        
        if #available(iOS 17.4, *),
           swiftPersistenceIsEnabled,
           let swiftDatabase = getSwiftDatabase(),
           let swiftPersistence = getAnySwiftPersistence(swiftDatabase: swiftDatabase) {
            
            return swiftPersistence
        }
        else {
            
            return RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType>(
                database: realmDatabase,
                dataModelMapping: realmDataModelMapping
            )
        }
    }

    @available(iOS 17.4, *)
    func getSwiftDatabase() -> SwiftDatabase? {
        
        guard swiftPersistenceIsEnabled else {
            return nil
        }
        
        return nil
    }
    
    @available(iOS 17.4, *)
    func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any Persistence<DataModelType, ExternalObjectType>)? {
        // NOTE: Subclasses should override and return a SwiftRepositorySyncPersistence. ~Levi
        return nil
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType> {
        
        return RealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType>(
            database: realmDatabase,
            dataModelMapping: realmDataModelMapping
        )
    }
}
