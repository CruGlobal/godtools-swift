//
//  MockMobileContentAuthTokenKeychainAccessor.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockMobileContentAuthTokenKeychainAccessor {
    
    private var userId: String?
    private var authTokenCodable: MobileContentAuthTokenDecodable?
    private var appleRefreshToken: String?
    
    func setUserId(_ userId: String?) {
        self.userId = userId
    }
}

extension MockMobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessorInterface {
    
    func saveMobileContentAuthToken(authTokenCodable: MobileContentAuthTokenDecodable) throws {
        self.authTokenCodable = authTokenCodable
        userId = authTokenCodable.userId
        appleRefreshToken = authTokenCodable.appleRefreshToken
    }
    
    func deleteMobileContentAuthTokenAndUserId(userId: String) {
        authTokenCodable = nil
        self.userId = nil
        appleRefreshToken = nil
    }
    
    func getMobileContentAuthToken(userId: String) -> String? {
        return authTokenCodable?.userId == userId ? authTokenCodable?.token : nil
    }
    
    func getMobileContentUserId() -> String? {
        return userId
    }
    
    func getAppleRefreshToken(userId: String) -> String? {
        return authTokenCodable?.userId == userId ? appleRefreshToken : nil
    }
}
