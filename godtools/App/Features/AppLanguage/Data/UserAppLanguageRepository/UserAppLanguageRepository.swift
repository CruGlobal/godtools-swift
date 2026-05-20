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
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
    
    func deleteLanguage() throws {
        
        try cache.deleteLanguage(id: Self.sharedUserId)
    }
    
    func getLanguage() -> UserAppLanguageDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: Self.sharedUserId)
        }
        catch _ {
            return nil
        }
    }
    
    func storeLanguage(appLanguageId: BCP47LanguageIdentifier) async throws {
        
        let dataModel = UserAppLanguageDataModel(
            id: Self.sharedUserId,
            languageId: appLanguageId
        )
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [dataModel],
            writeOption: nil,
            getOption: nil
        )
    }
}
