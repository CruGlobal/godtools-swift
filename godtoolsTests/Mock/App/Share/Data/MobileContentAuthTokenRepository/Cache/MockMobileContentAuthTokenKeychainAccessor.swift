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
    private var authToken: MobileContentAuthTokenDataModel?
    private var appleRefreshToken: String?
    
    func setUserId(_ userId: String?) {
        self.userId = userId
    }
}

extension MockMobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessorInterface {
    
    func saveMobileContentAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) throws {
        authToken = authTokenDataModel
        userId = authTokenDataModel.userId
        appleRefreshToken = authTokenDataModel.appleRefreshToken
    }
    
    func deleteMobileContentAuthTokenAndUserId(userId: String) {
        authToken = nil
        self.userId = nil
        appleRefreshToken = nil
    }
    
    func getMobileContentAuthToken(userId: String) -> String? {
        return authToken?.userId == userId ? authToken?.token : nil
    }
    
    func getMobileContentUserId() -> String? {
        return userId
    }
    
    func getAppleRefreshToken(userId: String) -> String? {
        return authToken?.userId == userId ? appleRefreshToken : nil
    }
}
