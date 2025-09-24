//
//  LanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LanguagesCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    // MARK: - Persistence
    
    func getPersistence() -> any RepositorySyncPersistence<LanguageDataModel, LanguageCodable> {
        
        if #available(iOS 17, *), let swiftPersistence = getSwiftPersistence() {
            return swiftPersistence
        }
        else {
            return getRealmPersistence()
        }
    }
    
    @available(iOS 17, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        
        guard let swiftDatabase = SharedSwiftDatabase.shared.swiftDatabase else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftLanguageDataModelMapping()
        )
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage> {
        return RealmRepositorySyncPersistence(
            realmDatabase: realmDatabase,
            dataModelMapping: RealmLanguageDataModelMapping()
        )
    }
    
    // MARK: - Query
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        if #available(iOS 17, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftLanguage> { object in
                object.code.localizedStandardContains(code)
            }
                    
            return swiftPersistence.getObjects(query: SwiftDatabaseQuery.filter(filter: filter)).first
        }
        else {
            
            let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
            
            return getRealmPersistence().getObjects(query: RealmDatabaseQuery.filter(filter: filter)).first
        }
    }
    
    func getCachedLanguages(languageCodes: [String]) -> [LanguageDataModel] {
        return languageCodes.compactMap({ getCachedLanguage(code: $0) })
    }
}
