//
//  UserToolFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class UserToolFiltersRepository {
    
    private static let userToolCategoryFilterId = "userToolCategoryFilter"
    private static let userToolLanguageFilterId = "userToolLanguageFilter"
    
    private let cache: UserToolFiltersCache
    
    init(cache: UserToolFiltersCache) {
        
        self.cache = cache
    }
    
    @MainActor func getUserToolCategoryFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache
            .categoryPersistence
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func getUserToolLanguageFilterChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache
            .languagePersistence
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getUserToolCategoryFilter() -> UserToolCategoryFilterDataModel? {
    
        do {
            return try cache.categoryPersistence.getDataModel(id: Self.userToolCategoryFilterId)
        }
        catch _ {
            return nil
        }
    }
    
    func getUserToolLanguageFilter() -> UserToolLanguageFilterDataModel? {
        
        do {
            return try cache.languagePersistence.getDataModel(id: Self.userToolLanguageFilterId)
        }
        catch _ {
            return nil
        }
    }
    
    func storeUserCategoryFilter(categoryId: String) async throws {
        
        let userId: String = Self.userToolCategoryFilterId
        
        try await storeCategoryFilter(id: userId, categoryId: categoryId)
    }
    
    private func storeCategoryFilter(id: String, categoryId: String) async throws {
        
        let categoryFilter = UserToolCategoryFilterDataModel(
            id: id,
            filterId: id,
            categoryId: categoryId,
            createdAt: Date()
        )
        
        _ = try await cache.categoryPersistence.writeObjectsAsync(
            externalObjects: [categoryFilter],
            writeOption: nil,
            getOption: nil
        )
    }
    
    func storeUserLanguageFilter(languageId: String) async throws {
        
        let userId: String = Self.userToolLanguageFilterId
        
        try await storeLanguageFilter(id: userId, languageId: languageId)
    }
    
    private func storeLanguageFilter(id: String, languageId: String) async throws {
        
        let languageFilter = UserToolLanguageFilterDataModel(
            id: id,
            filterId: id,
            languageId: languageId,
            createdAt: Date()
        )
        
        _ = try await cache.languagePersistence.writeObjectsAsync(
            externalObjects: [languageFilter],
            writeOption: nil,
            getOption: nil
        )
    }
    
    func deleteUserCategoryFilter() throws {
        try cache.deleteToolCategoryFilter(id: Self.userToolCategoryFilterId)
    }
    
    func deleteUserLanguageFilter() throws {
        try cache.deleteToolLanguageFilter(id: Self.userToolLanguageFilterId)
    }
}
