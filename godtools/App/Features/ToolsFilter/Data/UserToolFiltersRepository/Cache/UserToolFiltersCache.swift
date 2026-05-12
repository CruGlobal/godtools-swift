//
//  UserToolFiltersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class UserToolFiltersCache {
    
    let categoryPersistence: any Persistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel>
    let languagePersistence: any Persistence<UserToolLanguageFilterDataModel, UserToolLanguageFilterDataModel>
    
    init(
        categoryPersistence: any Persistence<UserToolCategoryFilterDataModel,
        UserToolCategoryFilterDataModel>, languagePersistence: any Persistence<UserToolLanguageFilterDataModel, UserToolLanguageFilterDataModel>
    ) {
        
        self.categoryPersistence = categoryPersistence
        self.languagePersistence = languagePersistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getCategorySwiftPersistence()?.database
    }
    
    private var realmDatabase: RealmDatabase? {
        return getCategoryRealmPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getCategorySwiftPersistence() -> SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolCategoryFilter>? {
        return categoryPersistence as? SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolCategoryFilter>
    }
    
    private func getCategoryRealmPersistence() -> RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolCategoryFilter>? {
        return categoryPersistence as? RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolCategoryFilter>
    }
    
    @available(iOS 17.4, *)
    private func getLanguageSwiftPersistence() -> SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolLanguageFilter>? {
        return languagePersistence as? SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolLanguageFilter>
    }
    
    private func getLanguageRealmPersistence() -> RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolLanguageFilter>? {
        return languagePersistence as? RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolLanguageFilter>
    }
}

extension UserToolFiltersCache {
    
    func deleteToolCategoryFilter(id: String) throws {
        
        if #available(iOS 17.4, *), let database = swiftDatabase {
            
            let context: ModelContext = database.openContext()
            
            let objectToDelete: SwiftUserToolCategoryFilter? = try database.read.object(context: context, id: id)
            
            try deleteSwiftObject(swiftObject: objectToDelete, context: context)
        }
        else if let realmDatabase = realmDatabase {
            
            let realm: Realm = try realmDatabase.openRealm()
            
            let objectToDelete: RealmUserToolCategoryFilter? = realmDatabase.read.object(realm: realm, id: id)
            
            try deleteRealmObject(realmObject: objectToDelete, realm: realm)
        }
    }
    
    func deleteToolLanguageFilter(id: String) throws {
        
        if #available(iOS 17.4, *), let database = swiftDatabase {
            
            let context: ModelContext = database.openContext()
            
            let objectToDelete: SwiftUserToolLanguageFilter? = try database.read.object(context: context, id: id)
            
            try deleteSwiftObject(swiftObject: objectToDelete, context: context)
        }
        else if let realmDatabase = realmDatabase {
            
            let realm: Realm = try realmDatabase.openRealm()
            
            let objectToDelete: RealmUserToolLanguageFilter? = realmDatabase.read.object(realm: realm, id: id)
            
            try deleteRealmObject(realmObject: objectToDelete, realm: realm)
        }
    }
    
    @available(iOS 17.4, *)
    private func deleteSwiftObject(swiftObject: (any IdentifiableSwiftDataObject)?, context: ModelContext) throws {
        
        guard let swiftObject = swiftObject, let database = swiftDatabase else {
            return
        }
        
        try database.write.context(
            context: context,
            writeObjects: WriteSwiftObjects(
                deleteObjects: [swiftObject],
                insertObjects: nil
            )
        )
    }
    
    private func deleteRealmObject(realmObject: (any IdentifiableRealmObject)?, realm: Realm) throws {
        
        guard let realmObject = realmObject, let realmDatabase = realmDatabase else {
            return
        }
        
        try realmDatabase.write.realm(realm: realm, writeClosure: { realm in
            
            return WriteRealmObjects(
                deleteObjects: [realmObject],
                addObjects: []
            )
        }, updatePolicy: .all)
    }
}
