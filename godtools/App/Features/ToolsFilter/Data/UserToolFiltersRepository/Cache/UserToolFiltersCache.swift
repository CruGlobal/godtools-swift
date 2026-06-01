//
//  UserToolFiltersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class UserToolFiltersCache {
    
    let categoryPersistence: any Persistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel>
    let languagePersistence: any Persistence<UserToolLanguageFilterDataModel, UserToolLanguageFilterDataModel>
    
    init(
        categoryPersistence: any Persistence<UserToolCategoryFilterDataModel,
        UserToolCategoryFilterDataModel>, languagePersistence: any Persistence<UserToolLanguageFilterDataModel, UserToolLanguageFilterDataModel>
    ) {
        
        self.categoryPersistence = categoryPersistence
        self.languagePersistence = languagePersistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getCategorySwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getCategorySwiftPersistence() -> SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolCategoryFilter>? {
        return categoryPersistence as? SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolCategoryFilter>
    }
    
    private func getCategoryRealmPersistence() -> RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolCategoryFilter>? {
        return categoryPersistence as? RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolCategoryFilter>
    }
    
    @available(iOS 17.4, *)
    private func getLanguageSwiftPersistence() -> SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolLanguageFilter>? {
        return languagePersistence as? SwiftRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, SwiftUserToolLanguageFilter>
    }
    
    private func getLanguageRealmPersistence() -> RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolLanguageFilter>? {
        return languagePersistence as? RealmRepositorySyncPersistence<UserToolCategoryFilterDataModel, UserToolCategoryFilterDataModel, RealmUserToolLanguageFilter>
    }
}

extension UserToolFiltersCache {
    
    func deleteToolCategoryFilter(id: String) async throws {
        
        _ = try await categoryPersistence.deleteObjectsByIds(ids: [id], getOption: nil)
    }
    
    func deleteToolLanguageFilter(id: String) async throws {
        
        _ = try await languagePersistence.deleteObjectsByIds(ids: [id], getOption: nil)
    }
}
