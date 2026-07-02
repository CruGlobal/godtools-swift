//
//  RealmUserAppLanguageCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift
import SwiftData

final class UserAppLanguageCache: Sendable {
            
    let persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel>
    
    init(persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, SwiftUserAppLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, SwiftUserAppLanguage>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, RealmUserAppLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<UserAppLanguageDataModel, UserAppLanguageDataModel, RealmUserAppLanguage>
    }
}

extension UserAppLanguageCache {
    
    func deleteLanguage(id: String) async throws {
            
        _ = try await persistence.deleteObjectsByIds(ids: [id], getOption: nil)
    }
}
