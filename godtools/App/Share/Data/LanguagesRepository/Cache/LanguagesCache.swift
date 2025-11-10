//
//  LanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LanguagesCache: SwiftElseRealmPersistence<LanguageDataModel, LanguageCodable, RealmLanguage> {
        
    init(realmDatabase: RealmDatabase) {
                
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmLanguageDataModelMapping()
        )
    }
    
    @available(iOS 17.4, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<LanguageDataModel, LanguageCodable>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftLanguageDataModelMapping()
        )
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
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            return swiftPersistence
                .getObjects(
                    query: SwiftDatabaseQuery.filter(
                        filter: getLanguageByCodePredicate(code: code)
                    )
                )
                .first
        }
        else {
                        
            return super.getRealmPersistence()
                .getObjects(
                    query: RealmDatabaseQuery.filter(
                        filter: getLanguageByCodeNSPredicate(code: code)
                    )
                )
                .first
        }
    }
    
    func getCachedLanguages(codes: [BCP47LanguageIdentifier]) -> [LanguageDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
                            
            return swiftPersistence
                .getObjects(
                    query: SwiftDatabaseQuery.filter(
                        filter: getLanguagesByCodesPredicate(codes: codes)
                    )
                )
        }
        else {
            
            return super.getRealmPersistence()
                .getObjects(
                    query: RealmDatabaseQuery.filter(
                        filter: getLanguagesByCodesNSPredicate(codes: codes)
                    )
                )
        }
    }
}
