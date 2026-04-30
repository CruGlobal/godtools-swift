//
//  UserAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

final class UserAppLanguageRepository {
        
    private static let sharedUserId: String = "shared-user-id"
    
    private let cache: UserAppLanguageCache
    
    init(cache: UserAppLanguageCache) {
        
        self.cache = cache
    }
    
    var persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel> {
        return cache.persistence
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .catch { (error: Error) in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteLanguage() throws {
        
        try cache.deleteLanguage(id: Self.sharedUserId)
    }
    
    func getCachedLanguage() -> UserAppLanguageDataModel? {
        
        do {
            return try persistence.getDataModel(id: Self.sharedUserId)
        }
        catch _ {
            return nil
        }
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
    
    private func storeLanguage(appLanguageId: BCP47LanguageIdentifier) async throws {
        
        let dataModel = UserAppLanguageDataModel(
            id: Self.sharedUserId,
            languageId: appLanguageId
        )
        
        _ = try await self.persistence.writeObjectsAsync(
            externalObjects: [dataModel],
            writeOption: nil,
            getOption: nil
        )
    }
    
    func storeLanguagePublisher(appLanguageId: BCP47LanguageIdentifier) -> AnyPublisher<Void, Error> {
        
        return AnyPublisher() {
            return try await self.storeLanguage(appLanguageId: appLanguageId)
        }
    }
}
