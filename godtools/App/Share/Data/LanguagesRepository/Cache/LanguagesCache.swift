//
//  LanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class LanguagesCache {
        
    let persistence: any Persistence<LanguageDataModel, LanguageCodable>
    
    init(persistence: any Persistence<LanguageDataModel, LanguageCodable>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>
    }
}

// MARK: - Predicates

extension LanguagesCache {
    
    @available(iOS 17.4, *)
    private func getLanguageByCodePredicate(code: String) -> Predicate<SwiftLanguage> {
     
        let filter = #Predicate<SwiftLanguage> { object in
            object.code == code
        }
        
        return filter
    }
    
    private func getLanguageByCodeNSPredicate(code: String) -> NSPredicate {
        
        let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
        
        return filter
    }
    
    @available(iOS 17.4, *)
    private func getLanguagesByCodesPredicate(codes: [String]) -> Predicate<SwiftLanguage> {
     
        let filter = #Predicate<SwiftLanguage> { object in
            codes.contains(object.code)
        }
        
        return filter
    }
    
    private func getLanguagesByCodesNSPredicate(codes: [String]) -> NSPredicate {
        
        let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) IN %@", codes)
        
        return filter
    }
}

// MARK: - Languages

extension LanguagesCache {
    
    func getLanguageByCode(code: BCP47LanguageIdentifier) throws -> LanguageDataModel? {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = SwiftDatabaseQuery<SwiftLanguage>.filter(
                filter: getLanguageByCodePredicate(code: code)
            )
            
            let swiftLanguage: SwiftLanguage? = try swiftPersistence.database.read.objects(context: swiftPersistence.database.openContext(), query: query).first
            
            if let swiftLanguage = swiftLanguage {
                return swiftLanguage.toModel()
            }
            else {
                return nil
            }
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm = try realmPersistence.database.openRealm()
            
            let query = RealmDatabaseQuery.filter(
                filter: getLanguageByCodeNSPredicate(code: code)
            )
            
            let realmLanguage: RealmLanguage? = realmPersistence.database.read.objects(realm: realm, query: query).first
            
            if let realmLanguage = realmLanguage {
                return realmLanguage.toModel()
            }
            else {
                return nil
            }
        }
        else {
            
            return nil
        }
    }
    
    func getLanguagesByCodes(codes: [BCP47LanguageIdentifier]) async throws -> [LanguageDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
                      
            let query = SwiftDatabaseQuery<SwiftLanguage>.filter(
                filter: getLanguagesByCodesPredicate(codes: codes)
            )
            
            return try await swiftPersistence
                .getDataModelsAsync(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery.filter(
                filter: getLanguagesByCodesNSPredicate(codes: codes)
            )
            
            return try await realmPersistence
                .getDataModelsAsync(getOption: .allObjects, query: query)
        }
        
        return Array()
    }
}
