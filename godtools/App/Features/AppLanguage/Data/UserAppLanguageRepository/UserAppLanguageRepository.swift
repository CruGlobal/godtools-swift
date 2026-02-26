//
//  UserAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class UserAppLanguageRepository {
        
    private static let sharedUserId: String = "shared-user-id"
    
    let cache: UserAppLanguageCache
    
    init(cache: UserAppLanguageCache) {
        
        self.cache = cache
    }
    
    func deleteLanguage() throws {
        
        try cache.deleteLanguage(id: Self.sharedUserId)
    }
    
    func getCachedLanguage() -> UserAppLanguageDataModel? {
        
        let dataModel: UserAppLanguageDataModel? = cache.persistence.getDataModelNonThrowing(id: Self.sharedUserId)
        
        return dataModel
    }
    
    func getCachedLanguagePublisher() -> AnyPublisher<UserAppLanguageDataModel?, Error> {
        
        do {
            
            let dataModel: UserAppLanguageDataModel? = try cache.persistence.getDataModel(id: Self.sharedUserId)
            
            return Just(dataModel)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func storeLanguagePublisher(appLanguageId: BCP47LanguageIdentifier) -> AnyPublisher<Void, Error> {
        
        let dataModel = UserAppLanguageDataModel(
            id: Self.sharedUserId,
            languageId: appLanguageId
        )
        
        return cache
            .persistence
            .writeObjectsPublisher(
                externalObjects: [dataModel],
                writeOption: nil,
                getOption: nil
            )
            .map { _ in
                return Void()
            }
            .eraseToAnyPublisher()
    }
}
