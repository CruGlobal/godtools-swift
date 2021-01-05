//
//  TheKeyUserAuthentication.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import TheKeyOAuthSwift
import GTMAppAuth

/*
 ----The OAuth client ID.----
 For client configuration instructions, see the [README](h ttps://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 Set to nil to use dynamic registration with this example.
 
let kClientID: String? = "2880599195946831054";
  Testing Client_ID 2880599195946831054
  Real Client_ID 5337397229970887848

----The OAuth redirect URI for the client @c kClientID.----
 For client configuration instructions, see the [README](h ttps://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 
let kRedirectURI: String = "ppoauthapp://h ttps://stage.godtoolsapp.com/auth";
  Testing RedirectURI ppoauthapp://https://stage.godtoolsapp.com/auth
  Real RedirectURI //https://godtoolsapp.com/auth

 ----NSCoding key for the authState property.----
let kAppAuthExampleAuthStateKey: String = "authState";
  */

class TheKeyUserAuthentication: NSObject, UserAuthenticationType {
    
    private let loginClient: TheKeyOAuthClient
    
    private var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    
    let authenticatedUser: ObservableValue<UserAuthModel?> = ObservableValue(value: nil)
    let didAuthenticateSignal: SignalValue<Result<UserAuthModel, Error>> = SignalValue()
    let didSignOutSignal: Signal = Signal()
    
    override init() {
        
        loginClient = TheKeyOAuthClient.shared
        
        super.init()
        
        let baseUrl: URL? = URL(string: "https://thekey.me/cas")
        let clientId: String = "5337397229970887848"
        let redirectUri: URL? = URL(string: "https://godtoolsapp.com/auth")
        
        if let baseUrl = baseUrl, let redirectUri = redirectUri {
            loginClient.configure(baseCasURL: baseUrl, clientID: clientId, redirectURI: redirectUri)
        }
        else {
            assertionFailure("Failed to configure loginClient.")
        }
        
        loginClient.addStateChangeDelegate(delegate: self)
        
        fetchUserIfAuthorized()
    }
    
    var isAuthenticated: Bool {
        return loginClient.isAuthenticated()
    }
    
    func canResumeAuthorizationFlow(url: URL) -> Bool {
        
        guard let currentFlow = currentAuthorizationFlow else {
            return false
        }
        
        currentAuthorizationFlow = nil
        
        return currentFlow.resumeAuthorizationFlow(with: url)
    }
    
    func createAccount(fromViewController: UIViewController) {
        
        internalAuthenticate(fromViewController: fromViewController, parameters: ["action":"signup"])
    }
    
    func signIn(fromViewController: UIViewController) {
        
        internalAuthenticate(fromViewController: fromViewController, parameters: nil)
    }
    
    func signOut() {
        loginClient.logout()
        didSignOutSignal.accept()
        authenticatedUser.accept(value: nil)
    }
    
    private func internalAuthenticate(fromViewController: UIViewController, parameters: [String: String]?) {
        
        currentAuthorizationFlow = loginClient.initiateAuthorization(
            requestingViewController: fromViewController,
            additionalParameters: parameters,
            callback: nil
        )
    }
    
    private func fetchUserIfAuthorized() {
        
        guard isAuthenticated else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            
            self?.loginClient.fetchAttributes() { [weak self] (attributes: [String: String]?, error: Error?) in
                
                let userAuthModel: UserAuthModel?
                
                if let error = error {
                    
                    userAuthModel = nil
                    
                    self?.didAuthenticateSignal.accept(value: .failure(error))
                }
                else if let attributes = attributes, let email = attributes["email"], !email.isEmpty  {
                    
                    let authModel = UserAuthModel(
                        email: email,
                        firstName: attributes["firstName"],
                        grMasterPersonId: attributes["grMasterPersonId"],
                        lastName: attributes["lastName"],
                        ssoGuid: attributes["ssoGuid"]
                    )
                    
                    userAuthModel = authModel
                    
                    self?.didAuthenticateSignal.accept(value: .success(authModel))
                }
                else {
                    
                    userAuthModel = nil
                    
                    let errorDescription: String = "An unknown error occurred.  Failed to fetch user attributes."
                    let unknownError = NSError(domain: "TheKeyUserAuthentication", code: -1, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                    
                    self?.didAuthenticateSignal.accept(value: .failure(unknownError))
                }
                
                self?.authenticatedUser.accept(value: userAuthModel)
            }
        }
    }
}

// MARK: - OIDAuthStateChangeDelegate

extension TheKeyUserAuthentication: OIDAuthStateChangeDelegate {
    func didChange(_ state: OIDAuthState) {
        fetchUserIfAuthorized()
    }
}
