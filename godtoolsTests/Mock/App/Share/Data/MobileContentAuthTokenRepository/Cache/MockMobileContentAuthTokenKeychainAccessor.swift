//
//  MockMobileContentAuthTokenKeychainAccessor.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockMobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessorInterface {
    
    var authToken: MobileContentAuthTokenDataModel?
    var userId: String?
    var appleRefreshToken: String?
    var shouldThrowError = false
    var deleteWasCalled = false
    var deletedUserId: String?
    
    init(authToken: MobileContentAuthTokenDataModel? = nil,
         userId: String? = nil,
         appleRefreshToken: String? = nil,
         shouldThrowError: Bool = false,
         deleteWasCalled: Bool = false,
         deletedUserId: String? = nil) {
        
        self.authToken = authToken
        self.userId = userId
        self.appleRefreshToken = appleRefreshToken
        self.shouldThrowError = shouldThrowError
        self.deleteWasCalled = deleteWasCalled
        self.deletedUserId = deletedUserId
    }
    
    func saveMobileContentAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) throws {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: -1)
        }
        authToken = authTokenDataModel
        userId = authTokenDataModel.userId
        appleRefreshToken = authTokenDataModel.appleRefreshToken
    }
    
    func deleteMobileContentAuthTokenAndUserId(userId: String) {
        deleteWasCalled = true
        deletedUserId = userId
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
