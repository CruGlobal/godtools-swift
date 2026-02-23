//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class MobileContentAuthTokenRepository {
    
    private let api: MobileContentAuthTokenAPIInterface
    private let cache: MobileContentAuthTokenCache
        
    init(api: MobileContentAuthTokenAPIInterface, cache: MobileContentAuthTokenCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func fetchRemoteAuthToken(providerToken: MobileContentAuthProviderToken, createUser: Bool) async throws -> Result<MobileContentAuthTokenDataModel, MobileContentApiError> {
        
        let result: Result<MobileContentAuthTokenDecodable, MobileContentApiError> = try await api.fetchAuthToken(
            providerToken: providerToken,
            createUser: createUser
        )
        
        switch result {
        case .success(let authTokenCodable):
                        
            try await cache.storeAuthToken(authTokenCodable: authTokenCodable)
            
            return .success(MobileContentAuthTokenDataModel(interface: authTokenCodable))
            
        case .failure(let apiError):
            
            return .failure(apiError)
        }
    }
    
    func getUserId() -> String? {
        
        return cache.getUserId()
    }
    
    func getAuthTokenChangedPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel?, Never> {
        
        return cache.getAuthTokenChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func getCachedAuthTokenModel() throws -> MobileContentAuthTokenDataModel? {
        
        guard let cachedAuthToken =  try cache.getCachedAuthToken() else {
            return nil
        }
        
        return MobileContentAuthTokenDataModel(authToken: cachedAuthToken)
    }
    
    func getCachedAuthToken() throws -> String? {
        
        return try getCachedAuthTokenModel()?.token
    }
    
    func deleteCachedAuthToken() throws {
        
        guard let userId = getUserId() else {
            return
        }
        
        try cache.deleteAuthToken(for: userId)
    }
}
