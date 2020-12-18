//
//  EmailSignUpService.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class EmailSignUpService {
    
    private let emailSignUpApi: EmailSignUpApi
    private let registeredEmailsCache: RegisteredEmailsCacheType
    
    required init(sharedSession: SharedSessionType, realmDatabase: RealmDatabase) {
        
        self.emailSignUpApi = EmailSignUpApi(sharedSession: sharedSession)
        self.registeredEmailsCache = RealmRegisteredEmailsCache(realmDatabase: realmDatabase)
    }
    
    func postEmailSignUpIfNeeded(email: String, firstName: String?, lastName: String?) -> OperationQueue? {
        
        let registeredEmail: RegisteredEmailModel? = registeredEmailsCache.getRegisteredEmail(email: email)
        let isRegistered: Bool = registeredEmail?.isRegisteredWithRemoteApi ?? false
        
        guard !isRegistered else {
            return nil
        }
        
        return emailSignUpApi.postEmailSignUp(email: email, firstName: firstName, lastName: lastName) { [weak self] (response: RequestResponse, result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) in
            
            let didRegisterWithRemoteApi: Bool
            
            switch result {
            case .success( _, _):
                didRegisterWithRemoteApi = true
            case .failure( _):
                didRegisterWithRemoteApi = false
            }
            
            let registeredEmail = RegisteredEmailModel(
                email: email,
                firstName: firstName,
                lastName: lastName,
                isRegisteredWithRemoteApi: didRegisterWithRemoteApi
            )
            
            self?.registeredEmailsCache.storeRegisteredEmail(model: registeredEmail)
        }
    }
}
