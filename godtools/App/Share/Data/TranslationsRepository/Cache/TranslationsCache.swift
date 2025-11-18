//
//  TranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class TranslationsCache: SwiftElseRealmPersistence<TranslationDataModel, TranslationCodable, RealmTranslation> {
         
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmTranslationDataModelMapping()
        )
    }
    
    @available(iOS 17.4, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<TranslationDataModel, TranslationCodable>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<TranslationDataModel, TranslationCodable, SwiftTranslation>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<TranslationDataModel, TranslationCodable, SwiftTranslation>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftTranslationDataModelMapping()
        )
    }
}

// MARK: - Query

extension TranslationsCache {
    
    func getTranslationsSortedByLatestVersion(resourceId: String, languageId: String) -> [TranslationDataModel] {
        
        // TODO: Add query for swiftdata. ~Levi
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
        }
        else {
            
        }
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            
            return Array()
        }
        
        return realmResource.getLatestTranslations()
            .filter("\(#keyPath(RealmTranslation.language.id)) = '\(languageId)'")
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
            .map({ TranslationDataModel(interface: $0 )})
        
    }
    
    func getTranslationsSortedByLatestVersion(resourceId: String, languageCode: String) -> [TranslationDataModel] {
        
        // TODO: Add query for swiftdata. ~Levi
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
        }
        else {
            
        }
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
           
            return Array()
        }
        
        return realmResource.getLatestTranslations()
            .filter(NSPredicate(format: "\(#keyPath(RealmTranslation.language.code)) = [c] %@", languageCode.lowercased()))
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
            .map({ TranslationDataModel(interface: $0 )})
    }
}
