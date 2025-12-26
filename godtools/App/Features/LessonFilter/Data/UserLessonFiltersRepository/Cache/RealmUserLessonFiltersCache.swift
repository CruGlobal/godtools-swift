//
//  RealmUserLessonFiltersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserLessonFiltersCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getUserLessonLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserLessonLanguageFilter.self)
            .objectWillChange
            .prepend(Void())
            .eraseToAnyPublisher()
    }
    
    func getUserLessonLanguageFilter(filterId: String) -> UserLessonLanguageFilterDataModel? {
        
        if let realmLanguageFilter = realmDatabase.openRealm()
            .object(ofType: RealmUserLessonLanguageFilter.self, forPrimaryKey: filterId) {
            
            return UserLessonLanguageFilterDataModel(realmUserLessonLanguageFilter: realmLanguageFilter)
        } else {
            
            return nil
        }
    }
    
    func storeUserLessonLanguageFilter(languageId: String, filterId: String) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmUserLessonLanguageFilter = RealmUserLessonLanguageFilter()
        realmUserLessonLanguageFilter.languageId = languageId
        realmUserLessonLanguageFilter.filterId = filterId
        
        do {
            
            try realm.write {
                realm.add(realmUserLessonLanguageFilter, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
}
