//
//  AppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

final class AppLanguagesRepository {
        
    private let api: AppLanguagesApi
    private let cache: AppLanguagesCache
    private let sync: AppLanguagesRepositorySyncInterface
    
    private var syncTask: Task<Void, Error>?
        
    init(api: AppLanguagesApi, cache: AppLanguagesCache, sync: AppLanguagesRepositorySyncInterface) {
        
        self.api = api
        self.cache = cache
        self.sync = sync
    }
    
    deinit {
        syncTask?.cancel()
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        
        syncAppLanguages()
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    var numberOfAppLanguages: Int {
        do {
            return try cache.persistence.getObjectCount()
        }
        catch _ {
            return 0
        }
    }
    
    func getLanguage(id: String) -> AppLanguageDataModel? {
        
        syncAppLanguages()
        
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    func getLanguages() async throws -> [AppLanguageDataModel] {
        
        syncAppLanguages()
        
        return try await cache.persistence.getDataModelsAsync(getOption: .allObjects)
    }
    
    private func syncAppLanguages() {
        
        guard syncTask == nil else {
            return
        }
        
        syncTask = Task { [weak self] in
            
            try await self?.sync.sync()
            
            self?.syncTask = nil
        }
    }
}
