//
//  PersonalizedToolsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import RepositorySync

class PersonalizedToolsCache {

    let persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>

    init(persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>) {

        self.persistence = persistence
    }

    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }

    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, SwiftPersonalizedTools>? {
        return persistence as? SwiftRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, SwiftPersonalizedTools>
    }

    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }

    func getRealmPersistence() -> RealmRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, RealmPersonalizedTools>? {
        return persistence as? RealmRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, RealmPersonalizedTools>
    }
}
