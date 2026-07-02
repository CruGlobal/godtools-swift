//
//  MockMobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

final class MockMobileContentAuthTokenCache: AuthTokenCacheInterface {
    
    init() {
        
    }
    
    func getUserId() -> String? {
        return nil
    }
    
    func getCachedAuthToken() throws -> CachedAuthToken? {
        return nil
    }
    
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenDecodable) async throws {
        
    }
    
    func deleteAuthToken(userId: String) async throws {
        
    }
    
    func getAuthTokenChangedPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel?, Never> {
        return Just(nil)
            .eraseToAnyPublisher()
    }
}
