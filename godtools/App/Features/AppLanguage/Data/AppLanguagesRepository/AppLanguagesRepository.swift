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
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    init(api: AppLanguagesApi, cache: AppLanguagesCache, sync: AppLanguagesRepositorySyncInterface) {
        
        self.api = api
        self.cache = cache
        self.sync = sync
    }
    
    var persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable> {
        return cache.persistence
    }
    
    @MainActor func observeNumberOfAppLanguagesPublisher() -> AnyPublisher<Int, Error> {
        
        sync.syncPublisher()
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
        
        return persistence
            .observeCollectionChangesPublisher()
            .tryMap { _ in
                return try self
                    .persistence
                    .getObjectCount()
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func observeAppLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Error> {
        
        sync.syncPublisher()
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
        
        return persistence
            .observeCollectionChangesPublisher()
            .flatMap({ (changes: Void) -> AnyPublisher<[AppLanguageDataModel], Error> in
                
                return self.persistence
                    .getDataModelsPublisher(getOption: .allObjects)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Error> {
        
        return sync.syncPublisher()
            .flatMap({ (syncCompleted: Void) -> AnyPublisher<[AppLanguageDataModel], Error> in
                
                return self.persistence
                    .getDataModelsPublisher(getOption: .allObjects)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<AppLanguageDataModel?, Error> {
        
        return sync.syncPublisher()
            .tryMap { _ in
                
                let dataModel: AppLanguageDataModel? = try self.persistence.getDataModel(id: languageId)
                
                return dataModel
            }
            .eraseToAnyPublisher()
    }
}
