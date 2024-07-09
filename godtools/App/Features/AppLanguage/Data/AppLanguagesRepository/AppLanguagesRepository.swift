//
//  AppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesRepository {
        
    private let cache: RealmAppLanguagesCache
    private let sync: AppLanguagesRepositorySyncInterface
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(cache: RealmAppLanguagesCache, sync: AppLanguagesRepositorySyncInterface) {
        
        self.cache = cache
        self.sync = sync
    }
    
    func observeNumberOfAppLanguagesPublisher() -> AnyPublisher<Int, Never> {
        
        sync.syncPublisher()
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        return cache.observeChangesPublisher()
            .flatMap({ (changes: Void) -> AnyPublisher<Int, Never> in
                return self.cache.getNumberOfLanguagesPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func observeAppLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        
        sync.syncPublisher()
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        return cache.observeChangesPublisher()
            .flatMap({ (changes: Void) -> AnyPublisher<[AppLanguageDataModel], Never> in
                return self.cache.getLanguagesPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        
        return sync.syncPublisher()
            .flatMap({ (syncCompleted: Void) -> AnyPublisher<[AppLanguageDataModel], Never> in
                
                return self.cache.getLanguagesPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<AppLanguageDataModel?, Never> {
        
        return sync.syncPublisher()
            .flatMap({ (syncCompleted: Void) -> AnyPublisher<AppLanguageDataModel?, Never> in
                
                return self.cache.getLanguagePublisher(languageId: languageId)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
