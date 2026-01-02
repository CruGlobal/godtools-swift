//
//  TranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

class TranslationsCache {
         
    private let persistence: any Persistence<TranslationDataModel, TranslationCodable>
    
    init(persistence: any Persistence<TranslationDataModel, TranslationCodable>) {
        
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<TranslationDataModel, TranslationCodable, SwiftTranslation>? {
        return persistence as? SwiftRepositorySyncPersistence<TranslationDataModel, TranslationCodable, SwiftTranslation>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<TranslationDataModel, TranslationCodable, RealmTranslation>? {
        return persistence as? RealmRepositorySyncPersistence<TranslationDataModel, TranslationCodable, RealmTranslation>
    }
}

// MARK: - Get Latest Translations

extension TranslationsCache {
    
    func getLatestTranslation(resourceId: String, languageId: String) throws -> TranslationDataModel? {
                
        if #available(iOS 17.4, *), let swiftDatabase = swiftDatabase {
            
            guard let translation = try getSwiftTranslationsSortedByLatestVersion(swiftDatabase: swiftDatabase, resourceId: resourceId, languageId: languageId).first else {
                return nil
            }
            
            return TranslationDataModel(interface: translation)
        }
        else if let realmTranslation = try getRealmTranslationsSortedByLatestVersion(resourceId: resourceId, languageId: languageId)?.first {
            
            return TranslationDataModel(interface: realmTranslation)
        }
        
        return nil
    }
    
    func getLatestTranslation(resourceId: String, languageCode: BCP47LanguageIdentifier) throws -> TranslationDataModel? {
        
        if #available(iOS 17.4, *), let swiftDatabase = swiftDatabase {
            
            guard let translation = try getSwiftTranslationsSortedByLatestVersion(swiftDatabase: swiftDatabase, resourceId: resourceId, languageCode: languageCode).first else {
                return nil
            }
            
            return TranslationDataModel(interface: translation)
        }
        else if let realmTranslation = try getRealmTranslationsSortedByLatestVersion(resourceId: resourceId, languageCode: languageCode)?.first {
            
            return TranslationDataModel(interface: realmTranslation)
        }
        
        return nil
    }
    
    @available(iOS 17.4, *)
    private func getResourceLatestTranslations(swiftDatabase: SwiftDatabase, resourceId: String) throws -> [SwiftTranslation] {
        
        let resource: SwiftResource? = try swiftDatabase.read.object(context: swiftDatabase.openContext(), id: resourceId)
        
        guard let resource = resource else {
            return Array()
        }
        
        let translations: [SwiftTranslation] = resource.latestTranslations
        
        return translations
    }
    
    @available(iOS 17.4, *)
    private func getSwiftTranslationsSortedByLatestVersion(swiftDatabase: SwiftDatabase, resourceId: String, languageId: String) throws -> [SwiftTranslation] {
        
        return try getResourceLatestTranslations(swiftDatabase: swiftDatabase, resourceId: resourceId)
            .filterByLanguageId(languageId: languageId)
            .sortByLatestVersionFirst()
    }
    
    @available(iOS 17.4, *)
    private func getSwiftTranslationsSortedByLatestVersion(swiftDatabase: SwiftDatabase, resourceId: String, languageCode: BCP47LanguageIdentifier) throws -> [SwiftTranslation] {
        
        return try getResourceLatestTranslations(swiftDatabase: swiftDatabase, resourceId: resourceId)
            .filterByLanguageCode(languageCode: languageCode)
            .sortByLatestVersionFirst()
    }
    
    private func getRealmTranslationsSortedByLatestVersion(resourceId: String, languageId: String) throws -> Results<RealmTranslation>? {
        
        guard let realmDatabase = realmDatabase else {
            return nil
        }
        
        guard let realmResource = try realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            
            return nil
        }
                
        return realmResource.getLatestTranslations()
            .filter("\(#keyPath(RealmTranslation.language.id)) = '\(languageId)'")
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
    }
    
    private func getRealmTranslationsSortedByLatestVersion(resourceId: String, languageCode: BCP47LanguageIdentifier) throws -> Results<RealmTranslation>? {
        
        guard let realmDatabase = realmDatabase else {
            return nil
        }
        
        guard let realmResource = try realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
           
            return nil
        }
        
        return realmResource.getLatestTranslations()
            .filter(NSPredicate(format: "\(#keyPath(RealmTranslation.language.code)) = [c] %@", languageCode.lowercased()))
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
    }
}
