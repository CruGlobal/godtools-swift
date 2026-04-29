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

final class PersonalizedToolsCache {

    let persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>

    init(persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>) {

        self.persistence = persistence
    }

    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }

    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, SwiftPersonalizedTools>? {
        return persistence as? SwiftRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, SwiftPersonalizedTools>
    }

    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }

    private func getRealmPersistence() -> RealmRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, RealmPersonalizedTools>? {
        return persistence as? RealmRepositorySyncPersistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel, RealmPersonalizedTools>
    }
}
