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
    
    private let realmDatabase: LegacyRealmDatabase
    private let realmDataModelMapping: any GTRepositorySyncMapping<DataModelType, ExternalObjectType, RealmObjectType>
        
    init(realmDatabase: LegacyRealmDatabase, realmDataModelMapping: any GTRepositorySyncMapping<DataModelType, ExternalObjectType, RealmObjectType>) {
        
        self.realmDatabase = realmDatabase
        self.realmDataModelMapping = realmDataModelMapping
    }
    
    func getPersistence() -> any GTRepositorySyncPersistence<DataModelType, ExternalObjectType> {
        
        if #available(iOS 17.4, *),
           let swiftDatabase = getSwiftDatabase(),
           let swiftPersistence = getAnySwiftPersistence(swiftDatabase: swiftDatabase) {
            
            return swiftPersistence
        }
        else {
            
            return GTRealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType>(
                realmDatabase: realmDatabase,
                dataModelMapping: realmDataModelMapping
            )
        }
    }

    @available(iOS 17.4, *)
    func getSwiftDatabase() -> SwiftDatabase? {
        return nil
    }
    
    @available(iOS 17.4, *)
    func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any GTRepositorySyncPersistence<DataModelType, ExternalObjectType>)? {
        // NOTE: Subclasses should override and return a GTSwiftRepositorySyncPersistence. ~Levi
        return nil
    }
    
    func getRealmPersistence() -> GTRealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType> {
        
        return GTRealmRepositorySyncPersistence<DataModelType, ExternalObjectType, RealmObjectType>(
            realmDatabase: realmDatabase,
            dataModelMapping: realmDataModelMapping
        )
    }
}
