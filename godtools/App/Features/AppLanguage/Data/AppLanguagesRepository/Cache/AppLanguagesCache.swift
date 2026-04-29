//
//  AppLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class AppLanguagesCache {
    
    let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
    
    init(persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<AppLanguageDataModel, AppLanguageCodable, SwiftAppLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<AppLanguageDataModel, AppLanguageCodable, SwiftAppLanguage>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<AppLanguageDataModel, AppLanguageCodable, RealmAppLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<AppLanguageDataModel, AppLanguageCodable, RealmAppLanguage>
    }
}
