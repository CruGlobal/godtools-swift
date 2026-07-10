//
//  MockMobileContentAuthTokenApi.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

@testable import godtools
import Foundation

final class MockMobileContentAuthTokenApi: AuthTokenApiInterface {
    
    private let fetchedAuthToken: MobileContentAuthTokenCodable?
    
    init(fetchedAuthToken: MobileContentAuthTokenCodable?) {
        self.fetchedAuthToken = fetchedAuthToken
    }
    
    func fetchAuthToken(providerToken: MobileContentAuthProviderToken, createUser: Bool) async throws -> Result<MobileContentAuthTokenCodable, MobileContentApiError> {
        
        guard let token = fetchedAuthToken else {
            return .failure(MobileContentApiError.other(error: NSError(domain: "TestError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No mock token configured"])))
        }
        
        return .success(token)
    }
}
