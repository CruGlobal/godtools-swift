//
//  EmailSignUpService.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class EmailSignUpService {
    
    private let api: EmailSignUpApi
    private let cache: RealmEmailSignUpsCache
    
    init(api: EmailSignUpApi, cache: RealmEmailSignUpsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func postNewEmailSignUpIfNeeded(emailSignUp: EmailSignUpModel) -> OperationQueue? {
        
        guard !cache.emailIsRegistered(email: emailSignUp.email) else {
            return nil
        }
        
        return postNewEmailSignUp(emailSignUp: emailSignUp)
    }
    
    private func postNewEmailSignUp(emailSignUp: EmailSignUpModel) -> OperationQueue {
        
        return api.postEmailSignUp(emailSignUp: emailSignUp) { [weak self] (response: RequestResponse) in
                        
            let httpStatusCode: Int = response.httpStatusCode ?? -1
            let httpStatusCodeFailed: Bool = httpStatusCode < 200 || httpStatusCode >= 400

            if !httpStatusCodeFailed {
                DispatchQueue.main.async {
                    let registeredEmailSignUp = EmailSignUpModel(model: emailSignUp, isRegistered: true)
                    self?.cache.cacheEmailSignUp(emailSignUp: registeredEmailSignUp)
                }
            }
        }
    }
}
