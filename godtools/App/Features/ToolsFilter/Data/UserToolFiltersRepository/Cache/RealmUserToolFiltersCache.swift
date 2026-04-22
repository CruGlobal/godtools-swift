//
//  RealmUserToolFiltersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

final class RealmUserToolFiltersCache {
    
    private static let userToolCategoryFilterId = "userToolCategoryFilter"
    private static let userToolLanguageFilterId = "userToolLanguageFilter"
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    @MainActor func getUserToolCategoryFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmUserToolCategoryFilter.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    @MainActor func getUserToolLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm()
            .objects(RealmUserToolLanguageFilter.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getUserToolCategoryFilter() -> UserToolCategoryFilterDataModel? {
        
        if let realmCategoryFilter = realmDatabase.openRealm()
            .object(ofType: RealmUserToolCategoryFilter.self, forPrimaryKey: Self.userToolCategoryFilterId) {
            
            return realmCategoryFilter.toModel()
        } else {
            
            return nil
        }
    }
    
    func getUserToolLanguageFilter() -> UserToolLanguageFilterDataModel? {
        
        if let realmLanguageFilter = realmDatabase.openRealm()
            .object(ofType: RealmUserToolLanguageFilter.self, forPrimaryKey: Self.userToolLanguageFilterId) {
            
            return realmLanguageFilter.toModel()
        } else {
            
            return nil
        }
    }
    
    func storeUserToolCategoryFilter(categoryId: String) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let id: String = Self.userToolCategoryFilterId
        
        let realmUserToolCategoryFilter = RealmUserToolCategoryFilter()
        realmUserToolCategoryFilter.filterId = id
        realmUserToolCategoryFilter.id = id
        realmUserToolCategoryFilter.categoryId = categoryId
        realmUserToolCategoryFilter.createdAt = Date()
        
        do {
            
            try realm.write {
                realm.add(realmUserToolCategoryFilter, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func storeUserToolLanguageFilter(languageId: String) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let id: String = Self.userToolLanguageFilterId
        
        let realmUserToolLanguageFilter = RealmUserToolLanguageFilter()        
        realmUserToolLanguageFilter.filterId = id
        realmUserToolLanguageFilter.id = id
        realmUserToolLanguageFilter.languageId = languageId
        realmUserToolLanguageFilter.createdAt = Date()
        
        do {
            
            try realm.write {
                realm.add(realmUserToolLanguageFilter, update: .modified)
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func removeUserToolCategoryFilter() {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmCategoryFilter = realm
            .object(ofType: RealmUserToolCategoryFilter.self, forPrimaryKey: Self.userToolCategoryFilterId) else { return }
        
        do {
            
            try realm.write {
                realm.delete(realmCategoryFilter)
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func removeUserToolLanguageFilter() {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmLanguageFilter = realm
            .object(ofType: RealmUserToolLanguageFilter.self, forPrimaryKey: Self.userToolLanguageFilterId) else { return }
        
        do {
            
            try realm.write {
                realm.delete(realmLanguageFilter)
            }
        }
        catch let error {
            print(error)
        }
    }
}
