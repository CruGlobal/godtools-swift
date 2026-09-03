//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class MobileContentAuthTokenRepository: Sendable {
    
    private let api: AuthTokenApiInterface
    private let cache: AuthTokenCacheInterface
        
    init(api: AuthTokenApiInterface, cache: AuthTokenCacheInterface) {
        
        self.api = api
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .observeCollectionChangesPublisher()
    }
    
    func fetchRemoteAuthToken(providerToken: MobileContentAuthProviderToken, createUser: Bool) async throws -> Result<MobileContentAuthTokenDataModel, MobileContentApiError> {
        
        let result: Result<MobileContentAuthTokenCodable, MobileContentApiError> = try await api.fetchAuthToken(
            providerToken: providerToken,
            createUser: createUser
        )
        
        switch result {
        case .success(let authTokenCodable):
                        
            try await cache.storeAuthToken(authTokenCodable: authTokenCodable)
            
            return .success(authTokenCodable.toModel())
            
        case .failure(let apiError):
            
            return .failure(apiError)
        }
    }
    
    func getUserId() -> String? {
        
        return cache.getUserId()
    }
    
    func getAuthToken() throws -> MobileContentAuthTokenDataModel? {
        
        guard let cachedAuthToken =  try cache.getAuthToken() else {
            return nil
        }
        
        return cachedAuthToken.toModel()
    }
    
    func getAuthTokenString() throws -> String? {
        
        return try getAuthToken()?.token
    }
    
    func deleteCachedAuthToken() async throws {
        
        guard let userId = getUserId() else {
            return
        }
        
        try await cache.deleteAuthToken(userId: userId)
    }
}
