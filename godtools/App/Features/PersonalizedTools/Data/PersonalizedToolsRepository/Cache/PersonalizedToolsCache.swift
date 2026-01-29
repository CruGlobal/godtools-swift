//
//  PersonalizedToolsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class PersonalizedToolsCache {

    private let realmDatabase: LegacyRealmDatabase
    private let personalizedToolsSync: RealmPersonalizedToolsCacheSync

    init(realmDatabase: LegacyRealmDatabase, personalizedToolsSync: RealmPersonalizedToolsCacheSync) {
        self.realmDatabase = realmDatabase
        self.personalizedToolsSync = personalizedToolsSync
    }
    
    @MainActor func getPersonalizedToolsChanged() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmPersonalizedTools.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getPersonalizedToolsFor(country: String, language: String) -> PersonalizedToolsDataModel? {

        let id = RealmPersonalizedTools.createId(country: country, language: language)

        guard let realmPersonalizedTools = realmDatabase.openRealm()
            .object(ofType: RealmPersonalizedTools.self, forPrimaryKey: id)
        else {
            return nil
        }

        return PersonalizedToolsDataModel(realmObject: realmPersonalizedTools)
    }
    
    func syncPersonalizedTools(_ personalizedTools: [PersonalizedToolsDataModel]) -> AnyPublisher<[PersonalizedToolsDataModel], Error> {
        
        return personalizedToolsSync.syncPersonalizedTools(personalizedTools)
    }
}
