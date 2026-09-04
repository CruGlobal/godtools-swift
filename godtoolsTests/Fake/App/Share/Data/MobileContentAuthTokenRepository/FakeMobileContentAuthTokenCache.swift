//
//  FakeMobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

final class FakeMobileContentAuthTokenCache: AuthTokenCacheInterface {
    
    init() {
        
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getUserId() -> String? {
        return nil
    }
    
    func getAuthToken() throws -> CachedAuthToken? {
        return nil
    }
    
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenCodable) async throws {
        
    }
    
    func deleteAuthToken(userId: String) async throws {
        
    }
}
