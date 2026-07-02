//
//  EmailSignUpService.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class EmailSignUpService {
    
    private let api: EmailSignUpApiInterface
    private let cache: EmailSignUpsCache
    
    init(api: EmailSignUpApiInterface, cache: EmailSignUpsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func postNewEmailSignUp(emailSignUp: EmailSignUp, requestPriority: RequestPriority) async throws {
        
        let emailIsRegistered: Bool = try cache.getEmailIsRegistered(email: emailSignUp.email)
                
        guard !emailIsRegistered else {
            return
        }
        
        let response = try await api.postEmailSignUp(emailSignUp: emailSignUp, requestPriority: requestPriority)
        
        let isSuccess: Bool = response.urlResponse.isSuccessHttpStatusCode
        
        if isSuccess {
            
            let registeredEmailSignUp = EmailSignUpDataModel(
                id: emailSignUp.email,
                email: emailSignUp.email,
                firstName: emailSignUp.firstName,
                lastName: emailSignUp.lastName,
                isRegistered: true
            )
            
            _ = try await cache.persistence
                .writeObjects(
                    externalObjects: [registeredEmailSignUp],
                    writeOption: nil,
                    getOption: nil
                )
        }
    }
}
