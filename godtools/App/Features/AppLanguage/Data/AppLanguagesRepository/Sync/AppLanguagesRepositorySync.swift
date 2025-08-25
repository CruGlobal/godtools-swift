//
//  AppLanguagesRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesRepositorySync: AppLanguagesRepositorySyncInterface {
        
    private let api: AppLanguagesApi
    private let cache: RealmAppLanguagesCache
    private let syncInvalidator: SyncInvalidator
    
    init(api: AppLanguagesApi, cache: RealmAppLanguagesCache, userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.api = api
        self.cache = cache
        self.syncInvalidator = SyncInvalidator(
            id: String(describing: AppLanguagesRepositorySync.self),
            timeInterval: .minutes(minute: 15),
            userDefaultsCache: userDefaultsCache
        )
    }
    
    func syncPublisher() -> AnyPublisher<Void, Never> {

        guard syncInvalidator.shouldSync else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
                
        return api.getAppLanguagesPublisher()
            .catch({ (error: Error) in
                return Just([])
                    .eraseToAnyPublisher()
            })
            .flatMap({ (appLanguages: [AppLanguageCodable]) -> AnyPublisher<[AppLanguageDataModel], Never> in
                
                let dataModels: [AppLanguageDataModel] = appLanguages.map({
                    AppLanguageDataModel(dataModel: $0)
                })
                
                return Just(dataModels)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (appLanguages: [AppLanguageDataModel]) -> AnyPublisher<Void, Never> in
                
                return self.cache.storeLanguagesPublisher(appLanguages: appLanguages)
                    .catch({ _ in
                        return Just([])
                            .eraseToAnyPublisher()
                    })
                    .map { _ in
                        
                        self.syncInvalidator.didSync()
                        
                        return ()
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
