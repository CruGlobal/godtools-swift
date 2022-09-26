//
//  EmailSignUpService.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class EmailSignUpService: NSObject {
    
    private let emailSignUpApi: EmailSignUpApi
    private let emailSignUpsCache: RealmEmailSignUpsCache
    private let oktaUserAuthentication: OktaUserAuthentication
    
    required init(sharedSession: SharedIgnoreCacheSession, realmDatabase: RealmDatabase, oktaUserAuthentication: OktaUserAuthentication) {
        
        self.emailSignUpApi = EmailSignUpApi(sharedSession: sharedSession)
        self.emailSignUpsCache = RealmEmailSignUpsCache(realmDatabase: realmDatabase)
        self.oktaUserAuthentication = oktaUserAuthentication
        
        super.init()
        
        setupBinding()
    }
    
    private func setupBinding() {
        
        oktaUserAuthentication.authenticatedUser.addObserver(self) { [weak self] (userAuth: OktaAuthUserModel?) in
            DispatchQueue.main.async { [weak self] in
                if let userAuth = userAuth {
                    let emailSignUp = EmailSignUpModel(email: userAuth.email, firstName: userAuth.firstName, lastName: userAuth.lastName)
                    _ = self?.postNewEmailSignUpIfNeeded(emailSignUp: emailSignUp)
                }
            }
        }
    }
    
    deinit {
        oktaUserAuthentication.authenticatedUser.removeObserver(self)
    }
    
    func postNewEmailSignUpIfNeeded(emailSignUp: EmailSignUpModel) -> OperationQueue? {
        
        guard !emailSignUpsCache.emailIsRegistered(email: emailSignUp.email) else {
            return nil
        }
        
        return postNewEmailSignUp(emailSignUp: emailSignUp)
    }
    
    private func postNewEmailSignUp(emailSignUp: EmailSignUpModel) -> OperationQueue {
        
        return emailSignUpApi.postEmailSignUp(emailSignUp: emailSignUp) { [weak self] (response: RequestResponse) in
                        
            let httpStatusCode: Int = response.httpStatusCode ?? -1
            let httpStatusCodeFailed: Bool = httpStatusCode < 200 || httpStatusCode >= 400

            if !httpStatusCodeFailed {
                DispatchQueue.main.async {
                    let registeredEmailSignUp = EmailSignUpModel(model: emailSignUp, isRegistered: true)
                    self?.emailSignUpsCache.cacheEmailSignUp(emailSignUp: registeredEmailSignUp)
                }
            }
        }
    }
}
