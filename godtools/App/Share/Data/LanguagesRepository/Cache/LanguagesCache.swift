//
//  LanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LanguagesCache: SwiftElseRealmPersistence<LanguageDataModel, LanguageCodable, RealmLanguage> {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmLanguageDataModelMapping()
        )
    }
    
    @available(iOS 17, *)
    override func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftLanguageDataModelMapping()
        )
    }
    
    // MARK: - Query
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        if #available(iOS 17, *), let swiftPersistence = super.getSwiftPersistence() {
            
            let filter = #Predicate<SwiftLanguage> { object in
                object.code.localizedStandardContains(code)
            }
                    
            return swiftPersistence.getObjects(query: SwiftDatabaseQuery.filter(filter: filter)).first
        }
        else {
            
            let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
            
            return super.getRealmPersistence().getObjects(query: RealmDatabaseQuery.filter(filter: filter)).first
        }
    }
    
    func getCachedLanguages(languageCodes: [String]) -> [LanguageDataModel] {
        return languageCodes.compactMap({ getCachedLanguage(code: $0) })
    }
}
