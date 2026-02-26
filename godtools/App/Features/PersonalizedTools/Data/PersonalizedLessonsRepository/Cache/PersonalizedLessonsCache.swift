//
//  PersonalizedLessonsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import RepositorySync

class PersonalizedLessonsCache {
    
    let persistence: any Persistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel>
    
    init(persistence: any Persistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel, SwiftPersonalizedLessons>? {
        return persistence as? SwiftRepositorySyncPersistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel, SwiftPersonalizedLessons>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel, RealmPersonalizedLessons>? {
        return persistence as? RealmRepositorySyncPersistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel, RealmPersonalizedLessons>
    }
}
