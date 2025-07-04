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

class EmailSignUpService {
    
    private let api: EmailSignUpApi
    private let cache: RealmEmailSignUpsCache
    
    init(api: EmailSignUpApi, cache: RealmEmailSignUpsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func postNewEmailSignUpPublisher(emailSignUp: EmailSignUpModel, requestPriority: RequestPriority) -> AnyPublisher<Void, Never> {
        
        guard !cache.emailIsRegistered(email: emailSignUp.email) else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        return api.postEmailSignUpPublisher(emailSignUp: emailSignUp, requestPriority: requestPriority)
            .map { (response: RequestDataResponse) in
                
                let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400

                if httpStatusCodeSuccess {
                    let registeredEmailSignUp = EmailSignUpModel(model: emailSignUp, isRegistered: true)
                    self.cache.cacheEmailSignUp(emailSignUp: registeredEmailSignUp)
                }

                return Void()
            }
            .catch { (error: Error) in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
