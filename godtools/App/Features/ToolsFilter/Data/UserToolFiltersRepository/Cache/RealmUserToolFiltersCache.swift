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

class RealmUserToolFiltersCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getUserToolCategoryFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserToolCategoryFilter.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getUserToolLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserToolLanguageFilter.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getUserToolCategoryFilter() -> UserToolCategoryFilterDataModel? {
        
        if let realmCategoryFilter = realmDatabase.openRealm()
            .object(ofType: RealmUserToolCategoryFilter.self, forPrimaryKey: RealmUserToolCategoryFilter.filterId) {
            
            return UserToolCategoryFilterDataModel(realmUserToolCategoryFilter: realmCategoryFilter)
        } else {
            
            return nil
        }
    }
    
    func getUserToolLanguageFilter() -> UserToolLanguageFilterDataModel? {
        
        if let realmLanguageFilter = realmDatabase.openRealm()
            .object(ofType: RealmUserToolLanguageFilter.self, forPrimaryKey: RealmUserToolLanguageFilter.filterId) {
            
            return UserToolLanguageFilterDataModel(realmUserToolLanguageFilter: realmLanguageFilter)
        } else {
            
            return nil
        }
    }
    
    func storeUserToolCategoryFilter(categoryId: String) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmUserToolCategoryFilter = RealmUserToolCategoryFilter()
        realmUserToolCategoryFilter.categoryId = categoryId
        
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
        
        let realmUserToolLanguageFilter = RealmUserToolLanguageFilter()
        realmUserToolLanguageFilter.languageId = languageId
        
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
            .object(ofType: RealmUserToolCategoryFilter.self, forPrimaryKey: RealmUserToolCategoryFilter.filterId) else { return }
        
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
            .object(ofType: RealmUserToolLanguageFilter.self, forPrimaryKey: RealmUserToolLanguageFilter.filterId) else { return }
        
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
