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

class MockMobileContentAuthTokenAPI: MobileContentAuthTokenAPIInterface {
    
    // Control test behavior
    var shouldReturnError = false
    var errorToReturn: MobileContentApiError = .other(error: NSError(domain: "TestError", code: -1))
    var authTokenToReturn: MobileContentAuthTokenDecodable?
    var delayInSeconds: TimeInterval = 0
    
    // Track method calls
    var fetchAuthTokenCallCount = 0
    var lastProviderToken: MobileContentAuthProviderToken?
    var lastCreateUserFlag: Bool?
    
    func fetchAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDecodable, MobileContentApiError> {
        
        // Track the call
        fetchAuthTokenCallCount += 1
        lastProviderToken = providerToken
        lastCreateUserFlag = createUser
        
        // Return error if configured
        if shouldReturnError {
            return Fail(error: errorToReturn)
                .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        // Return success with configured token
        guard let token = authTokenToReturn else {
            return Fail(error: MobileContentApiError.other(error: NSError(domain: "TestError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No mock token configured"])))
                .eraseToAnyPublisher()
        }
        
        return Just(token)
            .setFailureType(to: MobileContentApiError.self)
            .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // Helper methods for testing
    func reset() {
        fetchAuthTokenCallCount = 0
        lastProviderToken = nil
        lastCreateUserFlag = nil
        shouldReturnError = false
        authTokenToReturn = nil
        delayInSeconds = 0
    }
    
    func configureSuccess(with authToken: MobileContentAuthTokenDecodable) {
        shouldReturnError = false
        authTokenToReturn = authToken
    }
    
    func configureFailure(with error: MobileContentApiError) {
        shouldReturnError = true
        errorToReturn = error
    }
}
