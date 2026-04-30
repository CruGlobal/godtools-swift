//
//  UserLessonFiltersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class UserLessonFiltersCache {
    
    let persistence: any Persistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel>
    
    init(persistence: any Persistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel, SwiftUserLessonLanguageFilter>? {
        return persistence as? SwiftRepositorySyncPersistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel, SwiftUserLessonLanguageFilter>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel, RealmUserLessonLanguageFilter>? {
        return persistence as? RealmRepositorySyncPersistence<UserLessonLanguageFilterDataModel, UserLessonLanguageFilterDataModel, RealmUserLessonLanguageFilter>
    }
}
