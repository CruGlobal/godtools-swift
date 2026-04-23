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

final class RealmUserLessonFiltersCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    @MainActor func getUserLessonLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserLessonLanguageFilter.self)
            .objectWillChange
            .prepend(Void())
            .eraseToAnyPublisher()
    }
    
    func getUserLessonLanguageFilter(filterId: String) -> UserLessonLanguageFilterDataModel? {
        
        if let realmLanguageFilter = realmDatabase.openRealm()
            .object(ofType: RealmUserLessonLanguageFilter.self, forPrimaryKey: filterId) {
            
            return realmLanguageFilter.toModel()
        } else {
            
            return nil
        }
    }
    
    func storeUserLessonLanguageFilter(languageId: String, filterId: String) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmUserLessonLanguageFilter = RealmUserLessonLanguageFilter()
        realmUserLessonLanguageFilter.languageId = languageId
        realmUserLessonLanguageFilter.filterId = filterId
        realmUserLessonLanguageFilter.id = filterId
        realmUserLessonLanguageFilter.createdAt = Date()
        
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
