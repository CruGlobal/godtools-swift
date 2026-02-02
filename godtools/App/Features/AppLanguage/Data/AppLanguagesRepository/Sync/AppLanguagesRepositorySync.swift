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
    private let cache: AppLanguagesCache
    private let syncInvalidator: SyncInvalidator
    
    init(api: AppLanguagesApi, cache: AppLanguagesCache, syncInvalidator: SyncInvalidator) {
        
        self.api = api
        self.cache = cache
        self.syncInvalidator = syncInvalidator
    }
    
    func syncPublisher() -> AnyPublisher<Void, Error> {

        guard syncInvalidator.shouldSync else {
            return Just(Void())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
                
        return api
            .getAppLanguagesPublisher()
            .flatMap({ (appLanguages: [AppLanguageCodable]) -> AnyPublisher<Void, Error> in
                
                return self.cache
                    .persistence
                    .writeObjectsPublisher(
                        externalObjects: appLanguages,
                        writeOption: nil,
                        getOption: nil
                    )
                    .map { _ in
                        
                        self.syncInvalidator.didSync()
                        
                        return ()
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
