//
//  UserLessonProgressCache.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class UserLessonProgressCache {
    
    let persistence: any Persistence<UserLessonProgressDataModel, UserLessonProgressDataModel>
    
    init(persistence: any Persistence<UserLessonProgressDataModel, UserLessonProgressDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserLessonProgressDataModel, UserLessonProgressDataModel, SwiftUserLessonProgress>? {
        return persistence as? SwiftRepositorySyncPersistence<UserLessonProgressDataModel, UserLessonProgressDataModel, SwiftUserLessonProgress>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserLessonProgressDataModel, UserLessonProgressDataModel, RealmUserLessonProgress>? {
        return persistence as? RealmRepositorySyncPersistence<UserLessonProgressDataModel, UserLessonProgressDataModel, RealmUserLessonProgress>
    }
}
