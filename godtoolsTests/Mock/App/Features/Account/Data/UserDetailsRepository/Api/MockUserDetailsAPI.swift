//
//  MockUserDetailsAPI.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

@testable import godtools
import Foundation
import Combine
import RequestOperation

class MockUserDetailsAPI {
    
    private var fetchedUserDetails: MobileContentApiUsersMeCodable?
    
    func setMockFetchResponse(userDetails: MobileContentApiUsersMeCodable) {
        self.fetchedUserDetails = userDetails
    }
}

extension MockUserDetailsAPI: UserDetailsAPIInterface {
    
    func fetchUserDetailsPublisher(requestPriority: RequestPriority) -> AnyPublisher<MobileContentApiUsersMeCodable, any Error> {
        
        if let userDetails = fetchedUserDetails {
            return Just(userDetails)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock user details set"]))
                .eraseToAnyPublisher()
        }
    }
    
    func deleteAuthUserDetailsPublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, any Error> {
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
