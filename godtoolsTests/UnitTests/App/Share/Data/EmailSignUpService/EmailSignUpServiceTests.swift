//
//  EmailSignUpServiceTests.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RequestOperation
import RepositorySync

@Suite(.serialized)
struct EmailSignUpServiceTests {
    
    @Test()
    func postNewEmailSignUpWithSuccessHttpStatusCodeIsPersisted() async throws {
        
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200))
        
        let emailSignUpService = EmailSignUpService(
            api: MockEmailSignUpApi(result: result),
            cache: cache
        )
        
        let emailSignUp = EmailSignUp(email: "", firstName: nil, lastName: nil, isRegistered: false)
        
        try await emailSignUpService.postNewEmailSignUp(emailSignUp: emailSignUp, requestPriority: .high)
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getEmailSignUps().count
        
        #expect(count == 1)
    }
    
    @Test()
    func postNewEmailSignUpWithBadHttpStatusCodeIsNotPersisted() async throws {
        
        let cache = try getCache()
        
        let result: Result<RequestDataResponse, Error> = .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 400))
        
        let emailSignUpService = EmailSignUpService(
            api: MockEmailSignUpApi(result: result),
            cache: cache
        )
        
        let emailSignUp = EmailSignUp(email: "", firstName: nil, lastName: nil, isRegistered: false)
        
        try await emailSignUpService.postNewEmailSignUp(emailSignUp: emailSignUp, requestPriority: .high)
      
        try await Task.databaseChangesSleep()
        
        let count: Int = try cache.getEmailSignUps().count
        
        #expect(count == 0)
    }
}

extension EmailSignUpServiceTests {
    
    private func getTestsDiContainer() throws -> TestsDiContainer {
        return try TestsDiContainer(
            realmFileName: String(describing: EmailSignUpServiceTests.self)
        )
    }
    
    private func getCache() throws -> RealmEmailSignUpsCache {
        
        let testsDiContainer = try getTestsDiContainer()
        
        let cache = RealmEmailSignUpsCache(realmDatabase: testsDiContainer.dataLayer.getSharedRealmDatabase())
        
        return cache
    }
}
