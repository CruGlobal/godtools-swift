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

final class AppLanguagesRepository: Sendable {
        
    private let api: AppLanguagesApiInterface
    private let cache: AppLanguagesCache
            
    init(api: AppLanguagesApiInterface, cache: AppLanguagesCache) {
        
        self.api = api
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
                
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
                
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    func getLanguages() async throws -> [AppLanguageDataModel] {
                
        return try await cache.persistence.getDataModels(getOption: .allObjects)
    }
}
