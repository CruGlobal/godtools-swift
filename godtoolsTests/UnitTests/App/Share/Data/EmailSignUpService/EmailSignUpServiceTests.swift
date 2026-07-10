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
    
    private func getPersistence() throws -> any Persistence<EmailSignUpDataModel, EmailSignUpDataModel> {
        
        let databaseConfig = try RealmDatabaseConfig.createInMemoryConfig()
        
        return RealmRepositorySyncPersistence(
            database: RealmDatabase(databaseConfig: databaseConfig),
            mapping: RealmEmailSignUpMapping()
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
