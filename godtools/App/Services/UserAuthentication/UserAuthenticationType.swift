//
//  UserAuthenticationType.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol UserAuthenticationType {
    
    var authenticatedUser: ObservableValue<AuthUserModelType?> { get }
    var didAuthenticateSignal: SignalValue<Result<AuthUserModelType, Error>> { get }
    var didSignOutSignal: Signal { get }
    var isAuthenticated: Bool { get }
    
    func refreshAuthenticationIfAvailable()
    func createAccount(fromViewController: UIViewController)
    func signIn(fromViewController: UIViewController)
    func signOut(fromViewController: UIViewController)
    func getAuthenticatedUser(completion: @escaping ((_ result: Result<AuthUserModelType, Error>) -> Void))
}

extension UserAuthenticationType {
    
    var isAuthenticated: Bool {
        return authenticatedUser.value != nil
    }
}
