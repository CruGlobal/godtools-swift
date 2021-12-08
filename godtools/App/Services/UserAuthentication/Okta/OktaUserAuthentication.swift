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
        
    let authenticatedUser: ObservableValue<AuthUserModelType?> = ObservableValue(value: nil)
    let didAuthenticateSignal: SignalValue<Result<AuthUserModelType, Error>> = SignalValue()
    let didSignOutSignal: Signal = Signal()
    
    required init(oktaAuthentication: OktaAuthentication) {
        
        self.oktaAuthentication = oktaAuthentication
    }
    
    private func attemptAuthRefreshElseAuthenticate(authenticatefromViewController: UIViewController?) {
        
        if oktaAuthentication.refreshTokenExists {
            
            oktaAuthentication.renewAccessToken { [weak self] (result: Result<OktaAccessToken, OktaAuthenticationError>) in
                
                switch result {
                case .success(let accessToken):
                    self?.handleAuthenticationCompleteWithAccessToken(accessToken: accessToken)
                case .failure(let error):
                    if let fromViewController = authenticatefromViewController {
                        self?.authenticate(fromViewController: fromViewController)
                    }
                    else {
                        self?.handleAuthenticationFailedWithError(error: error)
                    }
                }
            }
        }
        else if let fromViewController = authenticatefromViewController {
            
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
        
        getAuthenticatedUser { [weak self] (result: Result<AuthUserModelType, Error>) in
            
            switch result {
           
            case .success(let authUser):
                
                self?.didAuthenticateSignal.accept(value: .success(authUser))
                self?.authenticatedUser.accept(value: authUser)
                
            case .failure(let error):
                
                self?.didAuthenticateSignal.accept(value: .failure(error))
                self?.authenticatedUser.accept(value: nil)
            }
        }
    }
    
    private func handleAuthenticationFailedWithError(error: OktaAuthenticationError) {
        
        didAuthenticateSignal.accept(value: .failure(mapOktaAuthenticationErrorToError(oktaAuthenticationError: error)))
    }
    
    private func mapOktaAuthenticationErrorToError(oktaAuthenticationError: OktaAuthenticationError) -> Error {
        
        switch oktaAuthenticationError {
        
        case .internalError( _, let message):
            
            let error: Error = NSError(
                domain: "OktaUserAuthentication",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Internal error found with message: \(message)"]
            )
            
            return error
        
        case .oktaSdkError(let error):
           
            return error
        }
    }
    
    func refreshAuthenticationIfAvailable() {

        attemptAuthRefreshElseAuthenticate(authenticatefromViewController: nil)
    }
        
    func createAccount(fromViewController: UIViewController) {
        
        attemptAuthRefreshElseAuthenticate(authenticatefromViewController: fromViewController)
    }
    
    func signIn(fromViewController: UIViewController) {
        
        attemptAuthRefreshElseAuthenticate(authenticatefromViewController: fromViewController)
    }
    
    func signOut(fromViewController: UIViewController) {
        
        oktaAuthentication.signOut(fromViewController: fromViewController) { [weak self] (removeFromSecureStorageError: Error?, signOutError: OktaAuthenticationError?, revokeError: Error?) in
            
            if signOutError == nil {
                self?.didSignOutSignal.accept()
                self?.authenticatedUser.accept(value: nil)
            }
        }
    }
    
    func getAuthenticatedUser(completion: @escaping ((_ result: Result<AuthUserModelType, Error>) -> Void)) {
        
        oktaAuthentication.getAuthorizedUserJsonObject { [weak self] (result: Result<[String: Any], OktaAuthenticationError>) in
            
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            
            case .success(let userJson):
                
                let authUserModel = AuthUserModel(
                    email: userJson["email"] as? String ?? "",
                    firstName: userJson["given_name"] as? String,
                    grMasterPersonId: userJson["grMasterPersonId"] as? String,
                    lastName: userJson["family_name"] as? String,
                    ssoGuid: userJson["ssoguid"] as? String
                )
                
                completion(.success(authUserModel))
                
            case .failure(let error):
                
                completion(.failure(weakSelf.mapOktaAuthenticationErrorToError(oktaAuthenticationError: error)))
            }
        }
    }
}
