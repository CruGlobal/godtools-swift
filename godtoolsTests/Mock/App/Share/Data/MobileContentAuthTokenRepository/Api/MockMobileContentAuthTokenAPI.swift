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
    
    func fetchAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDecodable, MobileContentApiError> {
        
        guard let token = fetchedAuthToken else {
            return Fail(error: MobileContentApiError.other(error: NSError(domain: "TestError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No mock token configured"])))
                .eraseToAnyPublisher()
        }
        
        return Just(token)
            .setFailureType(to: MobileContentApiError.self)
            .eraseToAnyPublisher()
    }
}
