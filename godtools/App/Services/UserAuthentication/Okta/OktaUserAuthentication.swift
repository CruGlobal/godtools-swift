//
//  OktaUserAuthentication.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import OktaAuthentication

class OktaUserAuthentication: UserAuthenticationType {
    
    private let oktaAuthentication: OktaAuthentication
    
    private(set) var isAuthenticated: Bool = false
    
    let authenticatedUser: ObservableValue<UserAuthModelType?> = ObservableValue(value: nil)
    let didAuthenticateSignal: SignalValue<Result<UserAuthModelType, Error>> = SignalValue()
    let didSignOutSignal: Signal = Signal()
    
    required init(oktaAuthentication: OktaAuthentication) {
        
        self.oktaAuthentication = oktaAuthentication
    }
    
    private func attemptAuthRefreshElseAuthenticate(fromViewController: UIViewController) {
        
        if oktaAuthentication.refreshTokenExists {
            
            oktaAuthentication.renewAccessToken { [weak self] (result: Result<OktaAccessToken, OktaAuthenticationError>) in
                
                switch result {
                case .success(let accessToken):
                    self?.handleAuthenticationCompleteWithAccessToken(accessToken: accessToken)
                case .failure( _):
                    self?.authenticate(fromViewController: fromViewController)
                }
            }
        }
        else {
            
            authenticate(fromViewController: fromViewController)
        }
    }
    
    private func authenticate(fromViewController: UIViewController) {
        
        oktaAuthentication.authenticate(fromViewController: fromViewController) { [weak self] (result: Result<OktaAccessToken, OktaAuthenticationError>) in
            
            switch result {
            case .success(let accessToken):
                self?.handleAuthenticationCompleteWithAccessToken(accessToken: accessToken)
            case .failure(let error):
                self?.handleAuthenticationFailedWithError(error: error)
            }
        }
    }
    
    private func handleAuthenticationCompleteWithAccessToken(accessToken: OktaAccessToken) {
        
        oktaAuthentication.getAuthorizedUserJsonObject { [weak self] (result: Result<[String: Any], OktaAuthenticationError>) in
            
            switch result {
            
            case .success(let userJson):
                
                let userAuthModel = UserAuthModel(
                    email: userJson["email"] as? String ?? "",
                    firstName: userJson["given_name"] as? String,
                    grMasterPersonId: userJson["grMasterPersonId"] as? String,
                    lastName: userJson["family_name"] as? String,
                    ssoGuid: userJson["ssoguid"] as? String
                )
                
                self?.isAuthenticated = true
                self?.didAuthenticateSignal.accept(value: .success(userAuthModel))
                self?.authenticatedUser.accept(value: userAuthModel)
                
            case .failure(let error):
                self?.isAuthenticated = false
                self?.didAuthenticateSignal.accept(value: .failure(error))
                self?.authenticatedUser.accept(value: nil)
            }
        }
    }
    
    private func handleAuthenticationFailedWithError(error: OktaAuthenticationError) {
        
        switch error {
        
        case .internalError( _, let message):
            
            let error: Error = NSError(
                domain: "OktaUserAuthentication",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Internal error found with message: \(message)"]
            )
            
            didAuthenticateSignal.accept(value: .failure(error))
        
        case .oktaSdkError(let error):
           
            didAuthenticateSignal.accept(value: .failure(error))
        }
    }
        
    func createAccount(fromViewController: UIViewController) {
        
        attemptAuthRefreshElseAuthenticate(fromViewController: fromViewController)
    }
    
    func signIn(fromViewController: UIViewController) {
        
        attemptAuthRefreshElseAuthenticate(fromViewController: fromViewController)
    }
    
    func signOut(fromViewController: UIViewController) {
        
        oktaAuthentication.signOut(fromViewController: fromViewController) { [weak self] (removeFromSecureStorageError: Error?, signOutError: OktaAuthenticationError?, revokeError: Error?) in
            
            if signOutError == nil {
                self?.isAuthenticated = false
                self?.didSignOutSignal.accept()
                self?.authenticatedUser.accept(value: nil)
            }
        }
    }
}
