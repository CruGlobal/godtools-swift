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
    
    let authenticatedUser: ObservableValue<UserAuthModel?> = ObservableValue(value: nil)
    let didAuthenticateSignal: SignalValue<Result<UserAuthModel, Error>> = SignalValue()
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
        
        oktaAuthentication.getAuthorizedUserJsonObject { (result: Result<[String: Any], OktaAuthenticationError>) in
            
            switch result {
            case .success(let userJson):
                print("did fetch cru user json: \(userJson)")
            case .failure(let error):
                print("Failed to get Cru User with error: \(error)")
            }
        }
        
        oktaAuthentication.getAuthorizedCruUser { [weak self] (result: Result<CruOktaUser, OktaAuthenticationError>) in
            
            switch result {
            case .success(let cruOktaUser):
                print("did fetch cru user")
            case .failure(let error):
                print("Failed to get Cru User with error: \(error)")
            }
        }
    }
    
    private func handleAuthenticationFailedWithError(error: OktaAuthenticationError) {
        
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
                self?.didSignOutSignal.accept()
                self?.authenticatedUser.accept(value: nil)
            }
        }
    }
    
    func signOut() {
        fatalError("Not supported by OktaUserAuthentication.  Call signOut(fromVieController: UIViewController)")
    }
}
