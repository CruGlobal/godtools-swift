//
//  MockMobileContentAuthTokenAPI.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

@testable import godtools
import Foundation
import Combine

class MockMobileContentAuthTokenAPI {
    
    private let fetchedAuthToken: MobileContentAuthTokenDecodable?
    
    init(fetchedAuthToken: MobileContentAuthTokenDecodable?) {
        self.fetchedAuthToken = fetchedAuthToken
    }
}

extension MockMobileContentAuthTokenAPI: MobileContentAuthTokenAPIInterface {
    
    func fetchAuthToken(providerToken: MobileContentAuthProviderToken, createUser: Bool) async throws -> Result<MobileContentAuthTokenDecodable, MobileContentApiError> {
        
        guard let token = fetchedAuthToken else {
            return .failure(MobileContentApiError.other(error: NSError(domain: "TestError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No mock token configured"])))
        }
        
        return .success(token)
    }
}
