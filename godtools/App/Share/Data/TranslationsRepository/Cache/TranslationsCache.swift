//
//  TranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class TranslationsCache: SwiftElseRealmPersistence<TranslationDataModel, TranslationCodable, RealmTranslation> {
         
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase, swiftPersistenceIsEnabled: Bool? = nil) {
        
        self.realmDatabase = realmDatabase
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmTranslationDataModelMapping(),
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
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

// MARK: - Get Latest Translations

extension TranslationsCache {
    
    func getLatestTranslation(resourceId: String, languageId: String) -> TranslationDataModel? {
                
        if #available(iOS 17.4, *), let swiftDatabase = super.getSwiftDatabase() {
            
            guard let translation = getSwiftTranslationsSortedByLatestVersion(swiftDatabase: swiftDatabase, resourceId: resourceId, languageId: languageId).first else {
                return nil
            }
            
            return TranslationDataModel(interface: translation)
        }
        else if let realmTranslation = getRealmTranslationsSortedByLatestVersion(resourceId: resourceId, languageId: languageId)?.first {
            
            return TranslationDataModel(interface: realmTranslation)
        }
        
        return nil
    }
    
    func getLatestTranslation(resourceId: String, languageCode: BCP47LanguageIdentifier) -> TranslationDataModel? {
        
        if #available(iOS 17.4, *), let swiftDatabase = super.getSwiftDatabase() {
            
            guard let translation = getSwiftTranslationsSortedByLatestVersion(swiftDatabase: swiftDatabase, resourceId: resourceId, languageCode: languageCode).first else {
                return nil
            }
            
            return TranslationDataModel(interface: translation)
        }
        else if let realmTranslation = getRealmTranslationsSortedByLatestVersion(resourceId: resourceId, languageCode: languageCode)?.first {
            
            return TranslationDataModel(interface: realmTranslation)
        }
        
        return nil
    }
    
    @available(iOS 17.4, *)
    private func getResourceLatestTranslations(swiftDatabase: SwiftDatabase, resourceId: String) -> [SwiftTranslation] {
        
        let resource: SwiftResource? = swiftDatabase.getObject(context: swiftDatabase.openContext(), id: resourceId)
        
        guard let resource = resource else {
            return Array()
        }
        
        let translations: [SwiftTranslation] = resource.latestTranslations
        
        return translations
    }
    
    @available(iOS 17.4, *)
    private func getSwiftTranslationsSortedByLatestVersion(swiftDatabase: SwiftDatabase, resourceId: String, languageId: String) -> [SwiftTranslation] {
        
        return getResourceLatestTranslations(swiftDatabase: swiftDatabase, resourceId: resourceId)
            .filterByLanguageId(languageId: languageId)
            .sortByLatestVersionFirst()
    }
    
    @available(iOS 17.4, *)
    private func getSwiftTranslationsSortedByLatestVersion(swiftDatabase: SwiftDatabase, resourceId: String, languageCode: BCP47LanguageIdentifier) -> [SwiftTranslation] {
        
        return getResourceLatestTranslations(swiftDatabase: swiftDatabase, resourceId: resourceId)
            .filterByLanguageCode(languageCode: languageCode)
            .sortByLatestVersionFirst()
    }
    
    private func getRealmTranslationsSortedByLatestVersion(resourceId: String, languageId: String) -> Results<RealmTranslation>? {
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            
            return nil
        }
                
        return realmResource.getLatestTranslations()
            .filter("\(#keyPath(RealmTranslation.language.id)) = '\(languageId)'")
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
    }
    
    private func getRealmTranslationsSortedByLatestVersion(resourceId: String, languageCode: BCP47LanguageIdentifier) -> Results<RealmTranslation>? {
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
           
            return nil
        }
        
        return realmResource.getLatestTranslations()
            .filter(NSPredicate(format: "\(#keyPath(RealmTranslation.language.code)) = [c] %@", languageCode.lowercased()))
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
    }
}
