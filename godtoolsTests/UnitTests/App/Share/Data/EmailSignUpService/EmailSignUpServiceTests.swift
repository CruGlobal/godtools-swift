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
import SwiftData

struct EmailSignUpServiceTests {
    
    @available(iOS 17.4, *)
    @Test()
    func postNewEmailSignUpWithSuccessHttpStatusCodeIsPersisted() async throws {
        
        let persistence = try getPersistence()
        
        let emailSignUpService = try getEmailSignUpService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 200)),
            persistence: persistence
        )
        
        let emailSignUp = EmailSignUp(email: "", firstName: nil, lastName: nil, isRegistered: false)
        
        try await emailSignUpService.postNewEmailSignUp(emailSignUp: emailSignUp, requestPriority: .high)
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 1)
    }
    
    @available(iOS 17.4, *)
    @Test()
    func postNewEmailSignUpWithBadHttpStatusCodeIsNotPersisted() async throws {
        
        let persistence = try getPersistence()
        
        let emailSignUpService = try getEmailSignUpService(
            apiResult: .success(try RequestDataResponse.createWithHttpStatusCode(httpStatusCode: 400)),
            persistence: persistence
        )
        
        let emailSignUp = EmailSignUp(email: "", firstName: nil, lastName: nil, isRegistered: false)
        
        try await emailSignUpService.postNewEmailSignUp(emailSignUp: emailSignUp, requestPriority: .high)
              
        let count: Int = try persistence.getObjectCount()
        
        #expect(count == 0)
    }
}

extension EmailSignUpServiceTests {
    
    @available(iOS 17.4, *)
    private func getPersistence() throws -> any Persistence<EmailSignUpDataModel, EmailSignUpDataModel> {

        return SwiftRepositorySyncPersistence(
            database: SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer()),
            mapping: SwiftEmailSignUpMapping()
        )
    }
    
    private func getEmailSignUpService(apiResult: Result<RequestDataResponse, Error>, persistence: any Persistence<EmailSignUpDataModel, EmailSignUpDataModel>) throws -> EmailSignUpService {
                
        return EmailSignUpService(
            api: FakeEmailSignUpApi(result: apiResult),
            cache: EmailSignUpsCache(
                persistence: persistence
            )
        )
    }
}
