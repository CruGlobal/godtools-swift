//
//  EmailSignUpService.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

final class EmailSignUpService {
    
    private let api: EmailSignUpApiInterface
    private let cache: RealmEmailSignUpsCache
    
    init(api: EmailSignUpApiInterface, cache: RealmEmailSignUpsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func postNewEmailSignUp(emailSignUp: EmailSignUp, requestPriority: RequestPriority) async throws {
        
        let emailIsRegistered: Bool = try cache.emailIsRegistered(email: emailSignUp.email)
        
        guard !emailIsRegistered else {
            return
        }
        
        let response = try await api.postEmailSignUp(emailSignUp: emailSignUp, requestPriority: requestPriority)
        
        let isSuccess: Bool = response.urlResponse.isSuccessHttpStatusCode
        
        if isSuccess {
            
            let registeredEmailSignUp = EmailSignUp(
                email: emailSignUp.email,
                firstName: emailSignUp.firstName,
                lastName: emailSignUp.lastName,
                isRegistered: true
            )
            
            self.cache.cacheEmailSignUp(emailSignUp: registeredEmailSignUp)
        }
    }
}
